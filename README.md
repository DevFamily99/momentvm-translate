# Momentvm Content Management

## Table of Content

{{TOC}}

## Architecture

### Microservices

The app is build from multiple micro services. Find them as abstract classes in `micro_service.rb`

## Rendering

### Render a page (Live Preview)

- render_page
	- render_live_editor_page(active_modules, all_templates, locale)
		- render_page_modules(active_modules, all_templates, locale)
		- render_image_url(:preview, rendered_modules)


- Render a preview
- Publish
- Render a xml


- Render modules to html (non-localized)
- Translate modules
- Render preview or publishing images
- Render the live editor helper
- Decorate modules with preview html

## languageWire integration

- Page has translation_status 0 or nil. Not sent
- Page has translation_status 1. Meaning it a document (frames for its translations) has been validated.
- Page has translation_status 2. Project has been created
- Page has translation_status 3. Project is done
