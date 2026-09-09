# Taxonomy/Term and Role-based Discounts for WooCommerce (free)

On WordPress.org. This is the free half of a two plugin product. The PRO add-on is a sibling
checkout at `../taxonomy-discounts-woocommerce-pro` and carries the fuller shared documentation in
its own `CLAUDE.md`, including the Subscriptions behaviour. Read it before changing anything the PRO
plugin hooks into, which is most of this codebase.

Nearly all the code is in `includes/class-wc-taxonomy-discounts-webdados.php` (~2900 lines).
Accessor: `WC_Taxonomy_Discounts_Webdados()`.

## This plugin owns the pipeline, PRO only plugs into it

PRO is an add-on and cannot run without this plugin at `WCTD_PRO_REQUIRED_FREE_VERSION` or above
(currently `8.5`, defined PRO side). Everything PRO does goes through `tdw_*` filters and actions
fired from here, so **a hook here is a public API**: renaming or dropping one silently breaks PRO,
and there is no error to notice, the callback just never runs.

Built in types are `array( 'percentage', 'x-for-y' )`, extended through `tdw_discount_types`. PRO
appends `pro-fixed`, `pro-stop` and `pro-subs-percentage-first-payment`. Every PRO type is `pro-`
prefixed. Anything reaching a `default:` branch is a type nothing active can handle, which happens
whenever PRO is deactivated, uninstalled, or running on an invalid or expired licence.

## The two price paths

They run at different times and share no code, so a change to one usually needs the same change to
the other:

1. **Catalog**: `on_get_price()` on `woocommerce_product_get_price`, priority from
   `$this->get_price_filter_priority`. Rule chosen by `get_product_applied_rule()`, which returns the
   **first** match in priority order.
2. **Cart**: `on_calculate_totals()` on `woocommerce_before_calculate_totals` at 99, with
   `cart_remove_price_filters()` at 98 removing the catalog filter first so prices cannot compound.

When they disagree the customer sees one price and is charged another.

## Cart item state

Applying a discount writes `$cart_item['taxonomy_discounts']` with `applied_rule`, `base_price`,
`display_price`, `discount_price`, `discount_display_price`. `base_price` is read from
`$product->get_price()`, not from post meta, on purpose: it means "what this item was worth before
we touched it", including a price another plugin set on the cart. It is the only correct value to
restore to. The key is unset in the same branch that restores `base_price`, so its absence reliably
means the price is not ours.

## Storage

Rules are term meta, key `tdw_discount_rule`, addressed by `meta_id` through direct `$wpdb` queries,
one row per rule. The admin edit and delete paths are gated by `tdw_rule_editable` /
`tdw_rule_deletable`, enforced server-side with `wp_die()`, with `tdw_rule_not_editable_or_deletable_notice`
for the explanation and `tdw_admin_rule_active_display` for the Active column.

## Conventions

- **Never bump the version** as part of a change. Unreleased changelog goes under `#### TBA` in
  `readme.txt`, entries ordered `[NEW]`, `[TWEAK]`, `[FIX]`, `[DEV]`, most visible first per tag.
- Changelog is read by shop owners. No file, class, hook or method names outside `[DEV]`, and no
  `[FIX]` for a bug that only ever existed in unreleased code.
- No em dashes or en dashes anywhere, including code comments.
- `phpcs` with the bundled `.phpcs.xml.dist` must stay clean.
- `_todo.txt` holds Marco's own backlog, in Portuguese. This file and `_todo.txt` are kept out of the
  WordPress.org ZIP by `.distignore`.
