#Goals for a better UI


> This is a plan to evolve the conductor UI into a lean, adaptive, beautiful and considered experience.


### Specifically, we hope to address:
* Navigating and issuing tasks quickly 
  * Without unnecessary http-roundtrips just to check on a view.
  * Without having to learn new components in every view
  * Without having to refer to documentation to be assisted in core tasks.

* Keeping the ‘big 6’ consistent:  
  * Consistent aesthetic
  * Consistent behaviour
  * Consistent notification 
  * Consistent messaging 
  * Consistent help
  * Consistent referencing

* Address as many media types as we can get *for free*
  * __Mobile__ - 480px and up via minor accommodations in our UI
  * __Workstation__ 640px-1280px - our default view
  * __Section 508__ compliance including screen readers
  * __Printable__ - As a read-only inventory manifest of a users entire access.

* Feel like a 2012 client app 
  * Cutting edge UI conventions
  * Swiss style visual metaphors & elements of typographic style
  * Baseline grid aligned typography consisting of 2 weights with single leading.
  * Use only vector graphics
  * Blazingly fast client side render times


# Glossary of terms / explanation of features.



## Views

One distinct category of content.

### explained

“the users view” or “the providers view”.
A views name can even be as specific as “userXX-provider-permissions view”  or “admin-provider-permissions-userXX view”

For more information on how we implement views, see 'View anchors' below

******


## Classes

Think HTML/CSS/JS classes

Classes track status or content type but not display.

 
    <a href="#provider23" class="provider23 enabling ec2" >online</a>`
    <div id="provider23" class="provider23 enabling ec2">Ec2…</div>

### Classing convention


#### Reserved classes

    .active 
is reserved for navigating views

    .enabling .disabling .verifying .deleting .requesting
are action classes reserved for client side action confirmation

    .enabled .disabled .verified .complete .building
are action classes reserved for server events

    .warning .note .info .tip .caution
are reserved for assistive content

    .static-reference .assist-reference
reserved for anchored clones of content via static and assistive referencing (see section)

    .progress .loading .building .compiling .altering
are progress classed to be used in conjunction with a numerical class

    .50 .10 .20 .25 .75 .100 .30 etc…
are percentage classes to be used in conjunction with a value

e.g.: `<span class="75 usage">75% of 300gb </...` 
or better: `<span class="75 usage">225gb of 300gb </...`

    .usage .progress .load .capacity
are **status** classes reserved for identifying the **type** of measurement

    .instance .provider .user .pool .group
are object classes to be used on any object 

###  Lack of classes for layout
We will __NOT__ use classes for defining grid layout e.g. `.span-12` or `.left-120/`

All layouts will be defined in CSS via a combination of their parent view and the relevant media query.


for example we will use the CSS 
    #admin #providers .account .summary{width:33.333%}
rather than relying on injecting style logic into the html like this `<class="summary span-4">`

******

## Graceful degradation

Support for all core functionality in as many scenarios as possible

 * New browser features (subtle animation, gradients etc)
 * Older browsers lacking features 
 * Browsers with javascript turned off
 * Screen readers (section 508, we’re going there)

******


## Responsive design

Support for viewing from various media eg  cellphones, touchscreen devices, kiosks, tv’s, even print.


### Explained

 1. We collapse tables into record views for narrow screens.
 2. We Grow fonts and icons for tremendously high resolutions or touchable large screens.
 3. We use only vector graphics (css /webfonts) for adaptive scaling and themeing.
Anchor referencing with js inlining means repeated content is printed only once.  a print version would read like an infrastructure status report from the users perspective.

******


## Visual Metaphors & Vector Graphics

Visual metaphors are graphics symbolic of the function they perform.
Vector graphics are a resolution independent implementation.

### Explained 
All icons, visual indicators and ornamental graphics  are implemented like this:

 * Vector glyphs are encoded into a woff webfont 
 * The woff font is base64 encoded in the stylesheet to minimise http requests (the current set of 30 icons is ~5k) so this is very acceptable.
 * We fallback to url linked images supplies for legacy browsers (no .WOFF support) by using [modernizr](http://www.modernizr.com/) classes `.no-webfonts` and `.webfonts` to discriminate our implementation through css


******

## View anchors - or 'single page app'

View anchors are portions of our design implemented within the one DOM using basic anchoring functionality.

### Explained
In the proposed change, the entire conductor is one page for all default views, 

1. Link anchors will activate the specific view or sub-view.  

2. Anchors that do not resolve will initiate a "cannot find" message which will most commonly occur when a user does not have access to an object and has manually entered a custom # URL.  the two exceptions to this will be ~/# and ~/#top which will initiate the default app view.

### In action

For example: 

> The URL below should open the admin > providers > ec2eastcoast > connectivity view.

    https://conductor/#ec2eastcoast-connectivity
               ^            ^              ^
            Server     ObjectID       ChildView


#### What the html does
e.g. the `<div>` representing admin > providers > ec2eastcoast would look like 

    <div id="ec2eastcoast">.. ec2 east coast information goes here


and the connectivity tab which exists inside the ec2eastcoast provider would look like 

    <div id="ec2eastcoast-connectivity">
                 ^             ^
             objectID       ChildViewname

Why?
Because the provider _ec2eastcoast_ lives natively within the _admin > provider_ section, it does not need to be referenced in the ID.. it simply has to be unique.  But because the connectivity tab is only unique because of the provider it is associated with, it needs to be prefixed with the objectID 


All direct links to the provider view would look like `<a href=#ec2eastcoast>EC2 East Coast</a> which would activate the provider tab.


#### what JS does

1. JS hides all non active views except for the default view (classed as active by the js)
2. 
3. when an ID is requested the object and all parent views get classed `.active` 
4. [hashchange for old browsers](http://benalman.com/projects/jquery-hashchange-plugin/)  to preserve browsing history

#### what the CSS does
The body class `.nojs` is removed once Javascript is loaded so the CSS specifies that only views be visible when they are classed as `.active` 

     
    .js div{display:none}         // Hiding all views
    .js div.active{display:block} // Showing active views
    .nojs div{display:block}      // All views are shown when tabs don't work.

******


## Referenced content

> Referenced content is a live-copy of any existing part of the application. It can be implemented with static references or assistive references 

> See [this JS Fiddle demo](http://jsfiddle.net/andyfitz/hRqGa/191/) 

#### example

1. Global help content can be referenced from many places at once so as to avoid redundancy and annoying ajax requests.. if the section the help comes from is loaded, so is the help.
2. Inspecting an object via a link can call the objects entire content into view.

******

### Static-references

Where an anchor link to another section has been replaced with a live copy of the section it links to.

    .static-reference

> An example would be any monitoring view that requires various metrics already rendered elsewhere be included.


******

### Assist-references

like a static reference but with the link-text preserved and the section only visible when the link-text has focus (has been clicked).

    .assist-reference

> An example would be a permissions editor referencing the objects that a user has permissions to by name  and allowing the user to inspect that object in-place with a single click, without having to visit the object in questions default view.

******


## Help & content

Written content to help describe a feature or scenario. 
Combined with admonition classes 

    .warning .note .info .tip .caution

Often implemented via one of the following methods 

 * Included in the view relevant to its description
 * As static-references where the help content can be dismissed (via an X in the top right corner)
 * As assist-references where the help content can be revealed upon clicking a referring link




Practically speaking this is text that can be placed inline with a view that it represents or hidden in a non displayed useful content area to be static or assist-referenced by many places.


### Explained

For example:  _“don’t be silly“_ is a generic tip that may apply to an enormous variety of contexts.  This is useful to be placed in the "generic tips" area and linked to via `<a href=”#dont be-silly” class=”assist-reference”>now please remember..</a>` which means it wil be rendered inline of where it is referenced.

******


##Client-side status polling

All objects relevant to a view are classed with the viewname
On any action inside the view, a status classname is added to the view as well as any objects that reference it regardless of where they are displayed  


    <a href=#user class=”userXX enabling”>link</a> 
    <div id=#”userXX” class=”userXX enabling” >UserXX View</div>.

We watch the referenced views classes and mimic them on all referencing links always as they can contain or be updated with new event styles (for example: failed, warning, upgraded, admin-only etc)

******

## Server status events *investigating*

Right now we can use ajax calls to update each view but in future it would make sense to use eventSource for more advanced monitoring: [eventSource: server sent events](http://html5doctor.com/server-sent-events/) 

******

## Client verification / fast feedback

Interactive assurance that an action has been requested without the verification that the server has performed the action.

For example a user clicks the enable button.. we immediately apply “enabling” status to the button but wait for the server to return with the “enabled” confirmation...

### How it works

> **Assumption** intermittent states like verifying, enabling and disabling states are safe for client side validation.

> They confirm an action has been requested but not applied.

As a rule, all elements are given the status of the objects they represent as well as classed with the object ID..  e.g.: all buttons with `class="providerid12451-*"` get the additional class of their intermittent state ``"enabling/disabling/verifying/whatever"``  When a functional object related to them has been actioned.

 1. On the client javascript side, we set the actioning classname to all elements with the same object objectid class.

 2. Once the action has been done an ajax call confirm the change and refreshes the class to "enabled/disabled/done/whatever" and removes the intermediary state

******

## Important action certification

[JS Fiddle demo](http://jsfiddle.net/andyfitz/mvdST/)


Requiring the user to certify that they understand the action before allowing it to take place.
for example:  

> “Do you understand what you are doing?[yes] okay, here’s the button [click]”

###explained

> Enabling and disabling providers,  deleting users etc 

We will use three methods to verify that a user has accepted the severity of the task they are about to perform:

 1. CSS physical obfuscation. 
Where the confirmation toggle sits physically on top of the action toggle so that an action can not be clicked without clicking the confirmation toggle first.  this helps simplify the component to one physical space part of the same consideration set.

 2. javascript validation.  
The action button beneath is disabled until the confirmation toggle has been clicked
 3. final server verification.  
the submitted action is not accepted by the system unless the post contains both the verification enabled and the action. the server then pushes the update


******

##Global status and system notification stack. 

Important information about the entire system or a current process, displayed prominently.
###explained

Using the referenced content heavily, we throw system, warning and notification content to the top of the page in a collapsing, growl-style notification system”

    <div id="notifications">
        <h1>System Messages</h1>
        
        <p class=”system”>you should to install aeolus-all to properly use conductor</p>
        
        <p class=”status provider123 build”>
          <a 
             href=”provider123-build-status” 
             class=”reflink 50”>
            building provider123 <span>50% Complete</span>
          </a>
        </p>

    </div>


******

## Printable manifest

Because our content is not replicated, and all enabled views are included in the DOM; 
our app can actually print as if it were a manifest for the authenticated user.

We get this feature for free by proxy of our method for referencing views and content.

Having the ability to produce a hard copy infrastructure report may be a gimmick, but it's an easy way to show how conductor can help respond an IT audit situation.

### example print stylesheet changes

    @media print {

    a:after {
        content: " ("attr(href)") ";}

    div:before{
        content: " ("attr(id)") ";}}

    }

This will preserve all references and links throughout the UI.

Also, we can manually define sections to be printed.

    @media print {

    div{display:none}

    #providers, #instances, #users, #global-tips {display:block !important}
 
   }

Which means only sections we desire to be included in the manifest get printed

also 

    @media print {

    .tabs:before{
       page-break-before: always;
       content:"This section contains the following:";
     .tabs li a:after{content:""}
     .tabs { font-size: 2em;page-break-after: always;}
     .tabs li{display:list}
    }

Which will convert our tabs into whole page section summaries.

> remember, this feature is free because we are designing conductor to gracefully degrade. Very little effort goes into preserving this feature so long as our standards are maintained.


# Existing conductor paradigms

These changes don't create any changes to terminology, or have much impact for pre-existing views for components already built into conductor.  It is likely that the majority of what has already been done will be preserved and only undergo minor changes to the HAML/SASS so that features may be integrated into the global view.

This has been written purely to start discussion on how we evolve Conductor going forward and I'd love to hear your thoughts: [andy.fitzsimon@redhat.com ](mailto:andy.fitzsimon@redhat.com)