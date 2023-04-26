# Vaunt Default Theme

A theme you can use to make your [Vaunt App](https://github.com/Casper64/vaunt).

![Screenshot 2023-04-11 000451](https://user-images.githubusercontent.com/43839798/231008104-687db058-b3ab-4f03-ae05-0b47de43164f.png)

## Requirements
Make sure you have V installed. You can check out the 
[documentation](https://github.com/vlang/v/#installing-v-from-source) to install V.

If you have installed V make sure you have the latest version installed by running `v up`.

Now you are able to import Vaunt directly into your projects with `import vaunt`!

## Database
For now Vaunt only supports PostgreSQL. You can start a database with 
```
sudo -u postgres psql -c "create database vaunt"
```

Change your credentials in `main.v` to connect to the database.

## Quick Start
Clone the repository and go into the directory
```
git clone https://github.com/Casper64/vaunt-default vaunt-app
cd vaunt-app
```

### Installation
Run `v install` to install Vaunt with the V package manager.
Now you are able to import Vaunt directly into your projects with `import vaunt`!


Start the dev server by running the following command:
```
v watch run src
```

## Admin Panel
The admin panel is accessible at the "/admin" route, or if you click the
`"Admin Panel"` button.

You can create and edit articles using the visual editor and when you're done just
hit the `publish` button to view the generated html.

## Theme Settings
You can edit the theme settings in the `Theme` section of the admin panel. Or by 
changing the default values in `src/theme.v`.

## Generate
You can generate the static site by passing the `--generate` flag or `-g` for short.
All files needed to host your website will be in the generated `public` directory.
```
v run src --generate
``` 

## Folder Structure
```tree
.
├── public   // contains all files to host your static website
├── static   // contains all static assets and will be available globally
├── uploads  // contains all image uploads
└── src      // project files
    ├── templates/
    │   ├── articles/    // Directory that contains all generated html for an article
    │   │   ├── [categories]    // category folders
    │   │   └── [id].html       // html for article with id=[id]
    │   ├── home.html    // Home page (index.html)
    │   └── layout.html  // Default layout
    ├── main.v  // entrypoint
    └── theme.v // theme settings
```

## CSS
`blocks.css`: An article will generate plain html, `blocks.css` contains all 
css used for styling the blocks.

`codemirror.css`: css for the code blocks. It uses the theme
[One Dark](https://github.com/codemirror/theme-one-dark).

`main.css`: General and layout styling.
