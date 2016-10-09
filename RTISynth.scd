// Nestor Napoles Lopez, 2016

(
SynthDef.new("RTISynth", {
	arg out = 0, freq = 440, amp = 0.2, gate = 1, a, d, s, r, pan = 0, addSlew= 0;
	var env, sin, pitch, panner;
	env = EnvGen.kr(Env.adsr(a, d, s, r, amp), gate);
	// Adding Slew if selected
	pitch = Select.kr(addSlew, [freq, Slew.kr(freq, 4000, 4000)]);
	sin = Saw.ar(pitch, mul:env);
	panner = Pan2.ar(sin, pan);
	Out.ar(out, panner);
}).send(s);
)

(
var func, scale, synth,
octavarray = [1, 1, 1, 1, 1, 1, 1, 1],
base = 2**(1/12),
// MODES
jonian = [1, base**2, base**4, base**5, base**7, base**9, base**11, 2],
dorian = [1, base**2, base**3, base**5, base**7, base**9, base**10, 2],
phrygian = [1, base**1, base**3, base**5, base**7, base**8, base**10, 2],
lydian = [1, base**2, base**4, base**6, base**7, base**9, base**11, 2],
mixolydian = [1, base**2, base**4, base**5, base**7, base**9, base**10, 2],
aeolian = [1, base**2, base**3, base**5, base**7, base**8, base**10, 2],
locrian = [1, base**1, base**3, base**5, base**6, base**8, base**10, 2];

func = {
	arg ratio_arr, baseFreq = 440, detune = 10, repeats= 1, a= 0.2, d= 0.1, s=0.9, r=1.0;
	var pitch, duration;
	Routine.new({
		synth = Synth.new("example 7", [\a, 0.2, \d, 0.1, \s, 0.9, \r, 0.5]);
		repeats.do ({
			ratio_arr.do({
				arg ratio, index;
				pitch = (ratio * baseFreq) + detune;
				duration = 0.2;
				synth.set(\freq, pitch, \gate, 1, \pan, 0);
				duration.wait;
				synth.set(\gate, 0.0);
			});
		});
	});
};
scale = jonian;
func.value(scale, 220, 10, inf).play;

//OSCFunc.trace(true);
OSCdef.new(\RTISynth,
	{
		arg msg, time, addr, recvPort;
		[msg, time, addr, recvPort].postln;
		synth.set(\addSlew, msg[1]);
	},
	'/1/slew'
);
)

(
var baseinterval = 2**(1/12);
baseinterval.postln;
)