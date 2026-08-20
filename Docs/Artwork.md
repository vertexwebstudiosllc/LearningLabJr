# Artwork updates

## Dolphin clean cutout

- **Mode:** built-in `image_gen`, edit / `background-extraction`. No CLI, API script, or pixel-processing fallback was used.
- **Source:** `Assets.xcassets/Animals/dolphin.imageset/dolphin.png`, inspected with `view_image` before editing. Its checkerboard was baked into an RGB PNG rather than represented by transparency.
- **New project asset:** `Assets.xcassets/Animals/dolphinClean.imageset/dolphinClean.png`; asset-catalog key `dolphinClean`. A new `Contents.json` registers a universal image.
- **Built-in output:** `/Users/vws/.codex/generated_images/01a0a164-a315-7f33-8a16-3fbac3ceed27/exec-41691758-7ed3-49a1-b6fb-04faf63b2f83.png`.
- **Preservation:** the original asset is unchanged. The generated PNG was copied byte-for-byte into the new image set; its alpha channel was preserved. No Swift routing edits were included in this asset task.
- **Visual review:** inspected the saved image with `view_image`. The complete left-facing smiling blue dolphin, white belly, eye, fins, and tail remain present. The checkerboard is removed, and all extremities fit within the canvas.
- **Validation:** 1254 × 1254, PNG color type 6 (RGBA), 8 bits per channel. All four corner alpha values are 0. There are 999,727 fully transparent pixels; most subject pixels have alpha 253 (near opaque). Representative belly and body samples are near opaque rather than holes. Native PNG parsing was used only to inspect metadata/alpha, not to alter pixels.
- **Original SHA-256:** `a83f5f5989240a96401d9edb1b04e624eeb563e43febc07b7cdb15617dfbcd50`.
- **New PNG SHA-256:** `c7058dc8fbfbf56272be23bb4af8efe898704a05a98fcf56992d50252f09dfef`.

### Final prompt

```text
Use case: background-extraction
Asset type: transparent PNG animal cutout for a toddler educational app.
Input image 1 is the EDIT TARGET: the supplied friendly blue cartoon dolphin, with a checkerboard baked into its background.
Primary request: remove the entire white and light-gray checkerboard background and make all background pixels truly transparent using a real alpha channel. Preserve the exact friendly blue dolphin, including its left-facing upright curved pose, large dark blue eye, open smiling mouth, white belly, fins, tail, blue outline, painterly shading, and original illustration style.
Composition/framing: one complete dolphin centered on a square transparent canvas, with a small comfortable transparent margin so every fin and the tail remain fully visible.
Constraints: change only the background and clean the cutout edge. Keep the dolphin’s identity, proportions, colors, pose, facial expression, details, and soft friendly appearance as close to the source as possible. Preserve white highlights and the white belly as opaque subject areas. Deliver actual transparency around the dolphin, not a drawn transparency pattern.
Avoid: checkerboard, white backdrop, gray backdrop, solid background, ground shadow, new props, water, bubbles, text, logos, border, watermark, crop, extra fins or tails.
```


## Apple clean cutout

- **Mode:** built-in `image_gen`, edit / `background-extraction`. No CLI, API script, or pixel-processing fallback was used.
- **Source:** `Assets.xcassets/Food/Apple.imageset/Apple.png`, inspected with `view_image` before editing.
- **New project asset:** `Assets.xcassets/Food/AppleClean.imageset/AppleClean.png`; asset-catalog key `AppleClean`. A new `Contents.json` registers a universal image.
- **Built-in output:** `/Users/vws/.codex/generated_images/01a0a164-6af2-7231-a70c-7a2676e8c124/exec-ea449e9d-ae80-480e-9fb1-ccb4d0353df0.png`.
- **Preservation:** the original image is unchanged. The generated PNG was copied byte-for-byte, preserving its alpha. No Swift references were changed in this asset task.
- **Visual review:** inspected the saved image with `view_image`. It retains the complete rounded red apple, green eyes, cheerful open smile, brown stem, upper-right green leaf, glossy texture, and front-facing pose. The baked checkerboard is removed, with transparent margins around the subject.
- **Validation:** native ImageIO/CoreGraphics inspection found 1254 × 1254 pixels with genuine alpha ranging from 0 to 255. All four corners are fully transparent; 659,107 of 1,572,516 pixels (41.9%) have zero alpha. Validation did not alter image pixels.
- **Original SHA-256:** `69775c90d4fc57d8cc4d849f6fcc39a2b3246af972bab39de69fc2daeca72108`.
- **New PNG SHA-256:** `03d75d6dfdc6c8afc49a4b9fb895e51d5e7edfee16b662755ad91d5ac70bae8f`.

### Final prompt

```text
Use case: background-extraction. Asset type: toddler educational app object sprite. Input image 1 is the edit target: the existing smiling red apple. Remove only the baked light gray and white checkerboard background and produce a genuinely transparent PNG with an alpha channel. Keep the apple itself unchanged as closely as possible: same rounded red silhouette, green eyes, eyebrows, cheerful open smile with red tongue, glossy red skin texture and highlights, brown stem, one green leaf leaning to the upper right, front-facing pose and centered composition. Preserve the entire apple, leaf, and stem with a small clear margin. Clean natural anti-aliased edges, no checkerboard pixels, no white outline or colored fringe. No ground, no background, no cast shadow, no extra objects, no text, no watermark. The background must be actual transparency, not a painted checkerboard or white fill.
```

