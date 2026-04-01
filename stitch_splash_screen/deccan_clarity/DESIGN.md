# Design System Specification: The Fluid Architect

## 1. Overview & Creative North Star
The "Fluid Architect" is the Creative North Star for this design system. While the foundation is built on utility and clarity for the Pune logistics and shifting market, the execution transcends the "utility app" stereotype. We are moving away from the rigid, boxed-in layouts of traditional service apps toward an **Editorial Logistics** aesthetic.

This system rejects the "template" look by utilizing intentional asymmetry, expansive white space, and a sophisticated tonal hierarchy. We treat the mobile screen not as a set of slots to be filled, but as a canvas where information flows naturally. By prioritizing "Breathing Room" over "Border Lines," we create an experience that feels premium, trustworthy, and effortlessly calm during the high-stress period of relocation.

## 2. Colors: Tonal Depth & The "No-Line" Rule
We use a palette rooted in trust (Blue) and clarity (White/Gray), but we apply them with a sophisticated layering strategy.

### The Palette (Material Design Convention)
*   **Primary (`#005DAC`):** Our core brand authority. Use for critical actions and brand presence.
*   **Primary Container (`#1976D2`):** A more vibrant blue used to draw attention to active states or key highlights.
*   **Surface / Background (`#F9F9F9`):** The base of our canvas.
*   **Surface Tiers:** 
    *   `surface-container-lowest`: `#FFFFFF` (Pure white for floating elements)
    *   `surface-container-low`: `#F3F3F3`
    *   `surface-container`: `#EEEEEE`
    *   `surface-container-high`: `#E8E8E8`

### The Rules of Engagement
*   **The "No-Line" Rule:** 1px solid borders for sectioning are strictly prohibited. You must define boundaries through background color shifts. For example, a `surface-container-lowest` card sits on a `surface-container-low` background. The eye perceives the edge through the shift in tone, not a drawn line.
*   **Surface Hierarchy & Nesting:** Treat the UI as physical layers of fine paper. An inner container (like a search bar) should use a slightly higher or lower tier than its parent container to define its importance.
*   **Signature Textures:** While the request avoids complex gradients, use a subtle "Atmospheric Fade" for Hero sections. Transitioning from `primary` (#005DAC) to `primary_container` (#1976D2) at a 15-degree angle provides a visual "soul" and depth that prevents the app from feeling flat or "budget."

## 3. Typography: The Editorial Scale
We use **Inter** to bridge the gap between technical precision and human readability. The hierarchy is designed to be "Top-Heavy," using large display type to anchor the user’s eye.

*   **Display (lg/md/sm):** 3.5rem to 2.25rem. Use these sparingly for welcome states or large numerical data (e.g., "30 Days until Move").
*   **Headline (lg/md/sm):** 2rem to 1.5rem. Use these to title major sections. Use `headline-lg` with `on_surface` (#1A1C1C) for a bold, editorial feel.
*   **Title (lg/md/sm):** 1.375rem to 1rem. These are the workhorses for card headers and navigation titles.
*   **Body (lg/md/sm):** 1rem to 0.75rem. Always use `body-lg` for user-generated content and `body-md` for descriptions to ensure high legibility for users on the move.
*   **Labels:** 0.75rem. Use for micro-copy and metadata.

## 4. Elevation & Depth: Tonal Layering
In this design system, depth is a feeling, not a feature. We replace traditional shadows with **Tonal Layering**.

*   **The Layering Principle:** Place a `surface-container-lowest` card on a `surface-container-low` section. This creates a soft, natural lift.
*   **Ambient Shadows:** If an element must float (like a FAB or a modal), use an ultra-diffused shadow: `Box-shadow: 0 12px 32px rgba(26, 28, 28, 0.06)`. The shadow color is a tinted version of our `on-surface` color, mimicking natural light.
*   **The "Ghost Border":** If a border is required for accessibility in input fields, use the `outline-variant` (#C1C6D4) at 20% opacity. 100% opaque borders are forbidden as they "trap" the content.
*   **Glassmorphism:** For top navigation bars or floating action buttons, use a background blur (12px to 20px) with a semi-transparent `surface` color. This makes the UI feel integrated and premium.

## 5. Components

### Buttons
*   **Primary:** Solid `primary` (#005DAC) with `on_primary` (#FFFFFF) text. Radius: 8px (0.5rem). No shadow.
*   **Secondary:** `surface-container-high` (#E8E8E8) background with `on_surface` text. This provides a "tactile" feel without the weight of the primary blue.
*   **Tertiary:** Ghost style. No background, just `primary` colored text. Used for less frequent actions like "Cancel" or "View Details."

### Cards & Lists
*   **The Rule of Separation:** Forbid the use of divider lines. Use vertical white space from our Spacing Scale (e.g., `8` (2rem) or `4` (1rem)) to separate content.
*   **Styling:** Use `surface-container-lowest` (#FFFFFF) for cards on a `surface` (#F9F9F9) background. Radius: `lg` (1rem) for a friendly, modern feel.

### Input Fields
*   **Default:** `surface-container` background with a `ghost border` (10% opacity `outline-variant`).
*   **Active:** `outline` (#717783) border at 100% opacity to signal focus clearly.
*   **Labels:** Always floating or positioned above the field using `label-md`.

### Contextual Components for Shiftease Pune
*   **Status Trackers:** Use asymmetric timelines. Instead of a centered line, use a heavy `primary` bar on the left with text pushed to the right, creating a sense of forward momentum.
*   **Inventory Chips:** Use `secondary-container` (#DFE0E0) for unselected items and `primary` for selected. Radius: `full`.

## 6. Do's and Don'ts

### Do
*   **Do** use asymmetrical spacing. A wider left margin (e.g., `6` / 1.5rem) compared to the right can create a high-end editorial rhythm.
*   **Do** prioritize high contrast for all text. Use `on_surface` (#1A1C1C) for all primary reading material.
*   **Do** use "Surface Tints" to group related information instead of drawing boxes around them.

### Don't
*   **Don't** use 1px solid black or dark gray borders. It cheapens the aesthetic.
*   **Don't** use standard drop shadows. If it doesn't look like it's naturally catching light, don't use it.
*   **Don't** clutter the screen. If a piece of information isn't vital to the "Shift," hide it behind a "More" action.
*   **Don't** use pure black (#000000). Always use `on_surface` (#1A1C1C) for a softer, more premium look.