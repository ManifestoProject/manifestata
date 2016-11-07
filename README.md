# manifestata

manifestata is a free add-on for the commerical statistical software Stata. It provides access to coded election programmes from the Manifesto Corpus and to the Manifesto Project's Main Dataset. 

## Functions
- provides access to the [Manifesto Corpus](/assets/view/statics/_corpus)
- downloads and loads the Manifesto Project Main Dataset in Stata
- and support for all other functions of the [Manifesto API](/assets/view/statics/_api).

## Prerequisites
- [Stata](http://www.stata.com/) - Version 14.0 or higher required.
- Manifesto Project Database Account (sign up on this webpage)
- Manifesto Project Database API Key (login to your account, go to your profile page and generate an API key)

## Installation
- Type the following commands in your command line in Stata:
- `net from https://manifesto-project.wzb.eu/manifestata`
- `net install manifestata`

## Documentation
- After installation, type `help manifestata` in Stata command window to view the documentation

## Contribute
You would like to contribute to the development of manifestata, eg. by integrating your preferred scaling procedure for the Main Dataset, [fork manifestata on Github](https://github.com/ManifestoProject/manifestata) and/or get in touch with us.

## Authors and Citation

 Ecker, Alejandro / Merz, Nicolas / Lewandowski, Jirka / Regel, Sven (2016): manifestata. A stata package to access the Manifesto Project's API. https://manifesto-project.wzb.eu/manifestata
