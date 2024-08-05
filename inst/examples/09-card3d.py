from fasthtml.common import *

def card_3d_demo():
	"""This is a standalone isolated Python component.
	Behavior and styling is scoped to the component."""
	# Python code credit: https://fastht.ml/
	# Design credit: https://codepen.io/markmiro/pen/wbqMPa
	bgurl = "https://ucarecdn.com/35a0e8a7-fcc5-48af-8a3f-70bb96ff5c48/-/preview/750x1000/"
	js_file = "/home/jordi/Projects/R-lang/ambhtmx/inst/examples/09-card3d.js"
	css_file = "/home/jordi/Projects/R-lang/ambhtmx/inst/examples/09-card3d.css"	
	card_styles ="font-family: 'Arial Black', 'Arial Bold', Gadget, sans-serif; perspective: 1500px;"
	def card_3d(text, background, amt, left_align):
		scr = ScriptX(js_file, amt=amt)
		align='left' if left_align else 'right'
		sty = StyleX(css_file, bgurl=f'url({background})', align=align)
		return Div(text, Div(), sty, scr)
	card = card_3d("Mouseover me", bgurl, amt=1.5, left_align=True)
	return Div(card, style=card_styles)

app,rt = fast_app()

@rt('/')
def get(): return card_3d_demo()

serve()
