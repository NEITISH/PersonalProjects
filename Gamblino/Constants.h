//
//  Constants.h
//  Gamblino
//
//  Created by JP Hribovsek on 11/4/13.
//  Copyright (c) 2013 Gamblino. All rights reserved.
//

#define kUserDefaultsAccessTokenKey @"Gamblino Access Token Key"
//#define kAPIBaseURL @"http://api.gamblinostaging.com"
//#define kAuthenticationURL @"http://oauth.gamblinostaging.com"
#define kAPIBaseURL @"https://api2.gamblino.com"
#define kAuthenticationURL @"https://oauth2.gamblino.com"
#define kAccessToken @"access_token"
#define kUserId @"userId"
#define kClientId @"63CE59F158AEE7839C652447673AF"
#define kClientSecret @"244A3CA5D2337F625C397C2EB378B"

//Common
#define kHeaderHeight 64.0
#define kScreenWidth 320.0
#define IS_IPHONE_4INCHES ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON )

//Add Friends
#define kFriendsSliderHeight 79.0

//Main menu
#define kMenuLineHeight 44.0
#define kMenuItemHome @"HOME"
#define kMenuItemAction @"ACTION"
#define kMenuItemContests @"CONTESTS"
#define kMenuItemPools @"POOLS"
#define kMenuItemGames @"GAMES"
#define kMenuItemMyWagers @"MY WAGERS"
#define kMenuItemProfile @"PROFILE"
#define kMenuItemPools @"POOLS"

//Conferences
#define kAllConferencesConferenceID -1

//Lines
#define kMoneyLineTitle @"MONEYLINE"
#define kStraightSpreadTitle @"STRAIGHT SPREAD"
#define kOverUnderTitle @"OVER / UNDER"
#define kMoneyType @"money"
#define kUnderType @"under"
#define kOverType @"over"
#define kSpreadType @"spread"
#define kCustomType @"custom"

//Contests
#define kContestTypeNational @"national"
#define kContestTypeLocal @"local"