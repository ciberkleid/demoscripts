# Create the theme file:
#wget https://raw.githubusercontent.com/sharkdp/bat/master/assets/themes/ansi-light.tmTheme -O ansi-light-MODIFIED.tmTheme

# Edit it: update value of lineHighlight to #F8EEC7

# To set it (done in setup.sh):
#mkdir -p "$(bat --config-dir)/themes"
# Copy theme file to config themes directory just created
#bat cache --build

# Need to change other settings? Try comparing to GitHub theme:
# https://github.com/AlexanderEkdahl/github-sublime-theme/tree/508740b2430c3c3a9e785fc93ee1d7c6f233af53