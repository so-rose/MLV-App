#include <stdio.h>
#include <stdint.h>
#include "delegate.h"
#include "../../src/mlv_include.h"
#include "main_methods.h"
#include "godobject.h"
extern godObject_t * App;

/* Make sure string memory block is long enough :D */
static void strReplace(char * str, char * find, char * replace)
{
    int find_len = strlen(find);
    int replace_len = strlen(replace);
    for (int i = 0; i < strlen(str); ++i)
    {
        if (!strncmp(str+i, find, find_len))
        {
            /* We have found a string */
            memmove(str+i+replace_len, str+i+find_len, strlen(str) - i);
            memcpy(str+i, replace, replace_len);
            i -= find_len;
        }
    }
}

/* Checks if str contains contains */
static int strContains(char * str, char * contains)
{
    uint64_t len = strlen(contains);
    uint64_t to = strlen(str) - len;
    for (uint64_t i = 0; i < to; ++i)
        if(!strncmp(str+i, contains, len)) return 1;
    return 0;
}

/* ISO 8601 "YYYY-MM-DDTHH:MM:SSZ" date to seconds since 1970. MIGHT be wrong. */
static uint64_t ISO8601toUnix(char * iso_date)
{
    uint64_t unix_time, yr, mo, d, h, m, s;
    char date[20];
    memcpy(date, iso_date, 19);
    date[4]=0;date[7]=0;date[10]=0;
    date[13]=0;date[16]=0;date[19]=0;
    sscanf(date, "%llu", &yr); /* years */
    unix_time = 31536000 * (yr-1970);
    unix_time += 86400 * ((yr-1972)/4); /* leap years */
    sscanf(date+5, "%llu", &mo); mo -= 1; /* months */
    if (mo<6) unix_time += mo*30 + (mo+1)/2 - ((mo%4)?1:2);
    else unix_time += 183 - ((mo%4)?1:2) + 30*(mo-6) + ((mo-5)/2);
    sscanf(date+8, "%llu", &d); /* days */
    unix_time += 86400 * d;
    sscanf(date+11, "%llu", &h); /* hours */
    unix_time += 3600 * h;
    sscanf(date+14, "%llu", &m); /* minutes */
    unix_time += 60 * m;
    sscanf(date+17, "%llu", &s); /* minutes */
    unix_time += s;
    return unix_time;
}

@implementation MLVAppDelegate

- (void)applicationWillFinishLaunching: (NSNotification *)notification
{
    NSMenu *newMenu;
    NSMenuItem *newItem;

    // Add the submenu
    newItem = [[NSMenuItem allocWithZone:[NSMenu menuZone]] initWithTitle:@"Flashy" action:NULL keyEquivalent:@""];
    newMenu = [[NSMenu allocWithZone:[NSMenu menuZone]] initWithTitle:@"Flashy"];
    [newItem setSubmenu:newMenu];
    [newMenu release];
    [[NSApp mainMenu] addItem:newItem];
    [newItem release];
}

- (void)applicationDidFinishLaunching: (NSNotification *)notification
{

    /* Check for updates... */
    // NSURL * releaseURL = [NSURL URLWithString: [NSString stringWithFormat: @"https://api.github.com/repos/ilia3101/MLV-App/releases"] ]; 
    // NSString * releaseString = [NSString stringWithContentsOfURL:releaseURL encoding:NSASCIIStringEncoding error:nil];
    // const char * releaseData = (const char *)[releaseString UTF8String];
    // char * releaseText = calloc(strlen(releaseData) * 3, sizeof(char)); /* With 3x extra space for other work */
    // memcpy(releaseText, releaseData, strlen(releaseData));
    // /* Do some fixing */
    // strReplace(releaseText, "\\n", "\n");
    // strReplace(releaseText, "\\r", "");
    // strReplace(releaseText, "**", "");
    // strReplace(releaseText, "### ", "");
    // strReplace(releaseText, "]", "");
    // strReplace(releaseText, "[", "");
    // strReplace(releaseText, ">", "    ");
    // strReplace(releaseText, "**", "");
    // printf("%s", releaseText);
}

/* Open an MLV file on startup */
- (BOOL)application: (NSApplication *)sender openFile: (NSString *)filename
{
    if (setAppNewMlvClip((char *)[filename UTF8String]))
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed: (NSApplication *)sender
{
    return YES;
}

@end