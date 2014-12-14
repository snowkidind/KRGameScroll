_  __                  _____             _
| |/ /                 |  __ \           | |
| ' / ___ _ __  _   _  | |__) |   _ _   _| |_ ___ _ __
|  < / _ \ '_ \| | | | |  _  / | | | | | | __/ _ \ '__|
| . \  __/ | | | |_| | | | \ \ |_| | |_| | ||  __/ |
|_|\_\___|_| |_|\__, | |_|  \_\__,_|\__, |\__\___|_|
                 __/ |               __/ |
                |___/               |___/
KR Game Scroll

contact
Keny Ruyter keny@eastcoastbands.com
http://twitter.com/snowkidind
http://kenyruyter.com

=====//=====

Integration Notes

The purpose of this program is to provide a method with which to manage 
multiple menu pages and present it in a scroller like fashion, either 
horizontally or vertically. It is designed to work with the entire 
screen of the device. It contains navigation boxes that tell you what 
page you are on.

See the file tutorial.txt to get more depth about the structure of the 
app. It covers building the included scroller app from scratch, save for 
the KRGameScroll class.

There are two ways you can go about architecting your menu scene. There 
may be many reasons to use either Method, if you want consolidated code 
just modify MenuPageTemplate to handle all your pages or just copy, 
paste and modify the class into separate custom pages. It is important 
to leave the MenuPageTemplate named as is because KRGameScroller uses 
it.

Possible Improvements:

1.	Make the scroller window independent of the width of the screen, 
that is, give the user an option to “scrunch” the pages so that you can 
see a little bit of the connected pages on either side e.g. badland; 
Allow for movement of the entire scroller object to accommodate for said 
dependency. 
2.	Make code available in swift

=====//=====

// Technical Gak:

Warranty Exclusion
------------------
You agree that this software is a
non-commercially developed program that may contain "bugs" (as that
term is used in the industry) and that it may not function as intended.
The software is licensed "as is". Keny Ruyter makes no, and hereby expressly
disclaims all, warranties, express, implied, statutory, or otherwise
with respect to the software, including noninfringement and the implied
warranties of merchantability and fitness for a particular purpose.

Limitation of Liability
-----------------------
In no event will Keny Ruyter be liable for any damages, including loss of data,
lost profits, cost of cover, or other special, incidental,
consequential, direct or indirect damages arising from the software or
the use thereof, however caused and on any theory of liability. This
limitation will apply even if Keny Ruyter has been advised of the possibility
of such damage. You acknowledge that this is a reasonable allocation of
risk.




