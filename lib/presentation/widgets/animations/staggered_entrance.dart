import 'package:flutter_animate/flutter_animate.dart';

/// Delay for the entrance animation of item [index] in a staggered
/// list/grid, capped so long lists don't take forever to finish animating in.
Duration staggeredDelay(int index) => (index * 40).clamp(0, 400).ms;
