# sendbetter.ai

Marketing site for SendBetter — automation, AI agents and software systems.
Built by Michael Laberge, Montreal.

## Structure

| Path | What it is |
| --- | --- |
| `index.html` | The whole site — a single page, EN/FR |
| `support.js` | Runtime that renders the `<x-dc>` template and bindings |
| `_ds/modernist-*/` | Modernist design system — `styles.css` + bundle |
| `assets/` | Photography |
| `.nojekyll` | Required: keeps GitHub Pages from stripping `_ds/` |

## Running locally

```
python3 -m http.server 8765
```

Then open http://localhost:8765. It is fully static — no build step.

## Notes

The contact form posts to Web3Forms. Its access key is a public client-side
key embedded in `index.html`; rotate it at web3forms.com if it attracts spam.
