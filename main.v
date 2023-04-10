module main

import vaunt
import vweb
import db.pg
import os
import time

const (
	template_dir = os.abs_path('templates') // where you want to store templates
	upload_dir   = os.abs_path('uploads') // where you want to store uploads
)

// Base app for Vaunt which you can extend
struct App {
	vweb.Context
pub:
	controllers  []&vweb.ControllerPath
	template_dir string                 [vweb_global]
	upload_dir   string                 [vweb_global]
pub mut:
	db     pg.DB  [vweb_global]
	dev    bool   [vweb_global] // used by Vaunt internally
	s_html string // used by Vaunt to generate html
}

fn main() {
	// insert your own credentials
	db := pg.connect(user: 'dev', password: 'password', dbname: 'vaunt')!
	// setup database and controllers
	controllers := vaunt.init(db, template_dir, upload_dir)!

	// create the app
	mut app := &App{
		template_dir: template_dir
		upload_dir: upload_dir
		db: db
		controllers: controllers
	}

	// serve all css files from 'static'
	app.handle_static('static', true)
	// start the Vaunt server
	vaunt.start(mut app, 8080)!
}

// The index.html page
['/']
pub fn (mut app App) home() vweb.Result {
	// html title
	title := 'Home'

	// get all articles that we want to display
	articles := vaunt.get_all_articles(mut app.db).filter(it.show == true)

	// render content into our layout
	content := $tmpl('./templates/home.html')
	layout := $tmpl('./templates/layout.html')

	// save the html for the generator
	app.s_html = layout
	return app.html(layout)
}

// Article pages
['/articles/:article_id']
pub fn (mut app App) article_page(article_id int) vweb.Result {
	// we don't want to render articles where `show` is set to `false`
	article := vaunt.get_article(mut app.db, article_id) or { return app.not_found() }
	if article.show == false {
		return app.not_found()
	}
	// html title
	title := 'Vaunt | ${article.name}'

	// If you press the `publish` button in the admin panel the html will be generated
	// and outputted to  `"[template_dir]/articles/[article_id].html"`.
	article_file := os.join_path(app.template_dir, 'articles', '${article_id}.html')
	// read the generated article html file
	content := os.read_file(article_file) or {
		eprintln(err)
		return app.not_found()
	}
	layout := $tmpl('./templates/layout.html')

	// save the html for the generator
	app.s_html = layout
	return app.html(layout)
}

// string format function used in templates
pub fn format_time(t_str string) string {
	t := time.parse(t_str) or { return '' }
	return t.md() + 'th'
}
