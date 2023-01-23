Thank you for purchasing SensorToolkit 2!

The documentation is available online at: http://www.micosmo.com/sensortoolkit2
There are some example scenes inside Examples/ directory. I recommend first viewing the 'Fundamentals' scene.

If you have any questions, feature requests or if you have found a bug then please send me an email at micosmogames@gmail.com


[CHANGELOG]
2.2.4 - Small improvement to Observable<T> class.
2.2.3 - Small tweaks to filtering functions. Slightly improved performance.
2.2.2 - LOSSensor has new prop 'PointGenerationMethod', which can be 'fast' or 'quality'. The 'quality' mode will restrict the test points to the fov, 'fast' will not.
2.2.1 - Small fix for LOSSensor. It should detect a signal when it's inside its bounds.
2.2.0 - Big improvements to LOSSensor. It will now generate test points within its defined angle constraints.
2.1.3 - Sensor pulses can now optionally be run in FixedUpdate. Fixed issue causing sensor pulses not to be staggered.
2.1.2 - Small bugfix. Signal.Bounds no longer throws NRE when Signal.Object is null.
2.1.1 - Small bugfixes for Playmaker actions.
2.1.0 - Added integration for Behavior Designer.
2.0.3 - Bugfix for LOSSensor so it will generate proper test points on rotated objects.
2.0.2 - Removed a List.AddRange which had slipped through and caused GC.
2.0.1 - No functional changes. Improved formatting and comments of all the sensors code.