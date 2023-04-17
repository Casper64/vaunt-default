module main

import vaunt

struct ThemeConfig {
pub mut:
	primary    vaunt.Color
	secondary  vaunt.Color
	background vaunt.Color
	text       vaunt.Color
	nav_align  vaunt.ClassList
}

fn get_theme() ThemeConfig {
	return ThemeConfig{
		primary: '#68a1d1'
		secondary: '#486581'
		background: '#ffffff'
		text: '#000000'
		nav_align: vaunt.ClassList{
			name: 'Navigation links aligmnent'
			selected: 'nav-center'
			options: {
				'nav-left':   'left'
				'nav-center': 'center'
				'nav-right':  'right'
			}
		}
	}
}
