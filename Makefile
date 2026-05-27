APP_NAME := MacCap

.PHONY: build app dmg clean-dist

build:
	swift build

app:
	./Scripts/build_app.sh

dmg:
	./Scripts/build_dmg.sh

clean-dist:
	rm -rf Dist
