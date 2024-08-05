from fasthtml.common import *

async def weather_table():
	"""Dynamically generated python content
	directly incorporated into the HTML"""
	# These are actual real-time weather.gov observations
	results = await all_weather()
	rows = [Tr(Td(city), *map(Td, d.values()), cls="even:bg-purple/5")
			for city,d in results.items()]
	flds = 'City', 'Temp (C)', 'Wind (kmh)', 'Humidity'
	head = Thead(*map(Th, flds), cls="bg-purple/10")
	return Table(head, *rows, cls="w-full")

app,rt = fast_app()

@rt('/')
def get(): return weather_table()

serve()
