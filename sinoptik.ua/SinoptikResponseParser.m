//
//  SinoptikResponseParser.m
//  
//
//  Created by shdwprince on 9/8/15.
//
//

#import "SinoptikResponseParser.h"

@implementation SinoptikResponseParser

- (DailyForecast *) parseForecast:(NSData *)htmlData {
    TFHpple *html = [[TFHpple alloc] initWithHTMLData:htmlData];

    NSArray *weatherDetailsTable = [html searchWithXPathQuery:@"//table[@class='weatherDetails']//tr"];
    NSMutableArray *data = [NSMutableArray new];

    int mode = weatherDetailsTable.count == 7 ? 7 : 9;
    int i = 0;
    for (TFHppleElement *column in weatherDetailsTable) {
        NSMutableArray *columnData = [NSMutableArray new];
        data[i++] = columnData;

        if (i == ((mode == 7) ? 7 : 8)) { // wind
            for (TFHppleElement *el in [column searchWithXPathQuery:@"//td//div"]) {
                NSString *direction_class = [[el.attributes[@"class"] componentsSeparatedByString:@" "] lastObject];
                NSString *direction = [[direction_class componentsSeparatedByString:@"-"] lastObject];
                [columnData addObject:[NSString stringWithFormat:@"%@%@", direction, el.text]];
            }
        } else if (i == 3) { // clouds
            for (TFHppleElement *el in [column searchWithXPathQuery:@"//img"]) {
                NSScanner *s = [NSScanner scannerWithString:el.attributes[@"src"]];
                [s scanUpToString:@"weatherImg/" intoString:nil];
                [s scanUpToString:@"/" intoString:nil];
                [s scanUpToString:@"/" intoString:nil];
                [s scanUpToCharactersFromSet:[NSCharacterSet decimalDigitCharacterSet] intoString:nil];
                NSInteger clouds = 0;
                [s scanInteger:&clouds];

                [columnData addObject:[NSNumber numberWithInteger:clouds]];
            }
        } else if (i == 4) {
            for (TFHppleElement *el in [column searchWithXPathQuery:@"//td"]) {
                [columnData addObject:[el.text substringToIndex:el.text.length - 1]];
            }
        } else {
            for (TFHppleElement *el in [column searchWithXPathQuery:@"//td"]) {
                if (el.text) {
                    [columnData addObject:el.text];
                }
            }
        }
    }

    NSMutableArray *daylight = [NSMutableArray new];
    for (TFHppleElement *el in [html searchWithXPathQuery:@"//div[@class='infoDaylight']//span"]) {
        if (el.text)
            [daylight addObject:el.text];
    }
    NSMutableArray *minMax = [NSMutableArray new];
    TFHppleElement *infoHistoryElement = [html searchWithXPathQuery:@"//p[@class='infoHistoryval']"].firstObject;
    int year_idx = 4;

    for (TFHppleElement *el in [html searchWithXPathQuery:@"//p[@class='infoHistoryval']//span"]) {
        if (el.text) {
            TFHppleElement *yearNode = infoHistoryElement.children[year_idx];
            NSString *yearString = [yearNode.content stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            [minMax addObject:[NSString stringWithFormat:@"%@ %@", el.text, yearString]];
        }

        year_idx = 10;
    }

    NSArray *description_elements = [html searchWithXPathQuery:@"//div[@class='description']"];
    NSString *summary = [(TFHppleElement *) [description_elements firstObject] content];
    summary = [summary stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

    DailyForecast *cast = [DailyForecast new];
    cast.daylight = daylight;
    cast.minMax = minMax;
    cast.summary = summary;

    for (int i = 0; i < [data[1] count]; i++) {
        HourlyForecast *forecast = [HourlyForecast new];

        int row = 3;
        forecast.temperature = [(NSString *) data[row++][i] integerValue];
        if (mode == 9)
            forecast.feelslikeTemperature = [(NSString *) data[row++][i] intValue];
        forecast.pressure = [(NSString *) data[row++][i] intValue];
        forecast.humidity = [(NSString *) data[row++][i] intValue];

        // wind data
        NSString *wind_data = data[row++][i];
        NSScanner *s = [NSScanner scannerWithString:wind_data];
        NSString *output;
        [s scanUpToCharactersFromSet:[NSCharacterSet decimalDigitCharacterSet] intoString:&output];
        [forecast setWindDirection:output];
        float f;
        [s scanFloat:&f];
        forecast.wind_speed = f;

        // rain & clouds data
        NSNumber *clouds_data = data[2][i];
        Byte clouds = 0;
        Byte rain = 0;
        Byte frost = 0;
        if (![clouds_data isEqual:@0]) {
            clouds = [[clouds_data.stringValue substringWithRange:NSMakeRange(0, 1)] integerValue];
            rain = [[clouds_data.stringValue substringWithRange:NSMakeRange(1, 1)] integerValue];
            frost = [[clouds_data.stringValue substringWithRange:NSMakeRange(2, 1)] integerValue];
        }

        forecast.clouds = clouds;
        forecast.rain = rain;
        forecast.frost = frost;
        if (mode == 9)
            forecast.rain_probability = [(NSString *) data[8][i] intValue];

        s = [NSScanner scannerWithString:data[1][i]];
        NSString *hour;
        [s scanUpToString:@":" intoString:&hour];

        forecast.hour = hour.intValue;
        cast.hourlyForecast[[NSNumber numberWithInteger:hour.integerValue]] = forecast;
    }

    return cast;
}

@end
