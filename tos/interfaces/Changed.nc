/**
 * Changed interface. Fired whenever the parameter value has changed.
 * Similar to Notify, but cannot be disabled by the user.
 *
 * @author Raido Pahtma
 * @license MIT
 */
interface Changed<val_t> {

	event void changed(val_t value);

}
