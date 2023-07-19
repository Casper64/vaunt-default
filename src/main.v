module main

import vaunt
import vweb
import db.sqlite
import time

const (
	template_dir = 'src/templates' // where you want to store templates
	upload_dir   = 'uploads' // where you want to store uploads
	app_secret   = 'my-256-bit-secret' // secret key used to generate secure hashes
)

// Base app for Vaunt which you can extend
struct App {
	vweb.Context
	vweb.Controller
	vaunt.Util
pub:
	template_dir string [vweb_global]
	upload_dir   string [vweb_global]
pub mut:
	dev   bool        [vweb_global] // used by Vaunt internally
	seo   vaunt.SEO   [vweb_global] // SEO configuration
	db    sqlite.DB
	theme ThemeConfig // Theming configuration
}

fn main() {
	// insert your own database
	db := sqlite.connect('app.db')!

	// init theme configuration
	theme := get_theme()
	// setup database and controllers
	controllers := vaunt.init(db, template_dir, upload_dir, theme, app_secret)!

	// create the app
	mut app := &App{
		template_dir: template_dir
		upload_dir: upload_dir
		db: db
		controllers: controllers
		// set SEO default settings
		seo: vaunt.SEO{
			// insert your website url below:
			// website_url: 'https://example.com'
			twitter: vaunt.Twitter{
				card_type: .summary
				site: '@your_name'
				creator: '@your_name'
			}
			og: vaunt.OpenGraph{
				site_name: 'Example'
				article: vaunt.OpenGraphArticle{
					// article author(s)
					author: ['Your Name']
				}
			}
		}
	}

	// serve all css files from 'static'
	app.handle_static('static', true)
	// start the Vaunt server
	vaunt.start(mut app, 8080)!
}

// fetch the new latest theme before processing a request
pub fn (mut app App) before_request() {
	// copy database connection to Util
	app.Util.db = app.db

	app.is_superuser = vaunt.is_superuser(mut app.Context, app_secret)
	// only update when request is a route, assuming all resources contain a "."
	if app.req.url.contains('.') == false {
		app.theme_css = vaunt.update_theme(app.db, mut app.theme)
	}
}

// The index.html page
['/']
pub fn (mut app App) home() vweb.Result {
	app.seo.og.title = 'My Blog'
	app.seo.set_description('My first blog with Vaunt')
	app.seo.set_url('')

	// html title
	title := 'Home'

	// render content into our layout
	content := $tmpl('templates/home.html')
	layout := $tmpl('templates/layout.html')

	// save the html for the generator
	app.s_html = layout
	return app.html(app.s_html)
}

// Article pages with a category
['/articles/:category_name/:article_name']
pub fn (mut app App) category_article_page(category_name string, article_name string) vweb.Result {
	article := vaunt.get_article_by_name(app.db, article_name) or { return app.not_found() }
	if article.show == false {
		return app.not_found()
	}
	// set seo automatically
	app.seo.set_article(article, app.req.url)

	// html title
	title := 'Vaunt | ${article.name}'

	article_html := app.category_article_html(category_name, article_name, template_dir) or {
		return app.not_found()
	}
	content := $tmpl('templates/article.html')
	layout := $tmpl('templates/layout.html')

	// save the html for the generator
	app.s_html = layout
	return app.html(app.s_html)
}

// Article pages without a category
['/articles/:article_name']
pub fn (mut app App) article_page(article_name string) vweb.Result {
	// we don't want to render articles where `show` is set to `false`
	article := vaunt.get_article_by_name(app.db, article_name) or { return app.not_found() }
	if article.show == false {
		return app.not_found()
	}
	// set seo automatically
	app.seo.set_article(article, app.req.url)

	// html title
	title := 'Vaunt | ${article.name}'

	article_html := app.article_html(article_name, template_dir) or { return app.not_found() }
	content := $tmpl('templates/article.html')
	layout := $tmpl('templates/layout.html')

	// save the html for the generator
	app.s_html = layout
	return app.html(app.s_html)
}

// Page for each tag
['/tags/:tag_name']
pub fn (mut app App) tag_page(tag_name string) vweb.Result {
	tag := app.get_tag(tag_name) or { return app.not_found() }
	title := 'Vaunt | ${tag.name}'

	content := $tmpl('templates/tag.html')
	layout := $tmpl('templates/layout.html')

	// save the html for the generator
	app.s_html = layout
	return app.html(app.s_html)
}

// will be generated to `about.html` when no route attribute is provided
pub fn (mut app App) about() vweb.Result {
	app.seo.og.title = 'About Me'
	app.seo.set_description('This is a page about me')
	app.seo.set_url(app.req.url)

	// html title
	title := 'Vaunt | About'

	// render content into our layout
	content := $tmpl('templates/about.html')
	layout := $tmpl('templates/layout.html')

	// save the html for the generator
	app.s_html = layout
	return app.html(layout)
}

// redirect to home when an url is not found
pub fn (mut app App) not_found() vweb.Result {
	return app.redirect('/')
}

// string format function used in home.html
pub fn format_time(t_str string) string {
	t := time.parse(t_str) or { return '' }
	return t.md() + 'th'
}
