// Nestor Napoles Lopez, 2016

(
SynthDef.new("RTISynth", {
	arg freq, amp, gate, a, d, s, r, slew, osctype;
	var env, sin, pitch, panner;
	env = EnvGen.kr(Env.adsr(a, d, s, r, amp), gate);
	// Adding Slew if selected
	pitch = Select.kr(slew, [freq, Slew.kr(freq, 4000, 4000)]);
	// Using the right oscillator
	sin = Select.ar(osctype, [SinOsc.ar(pitch, mul:env), LFPulse.ar(pitch, mul:env), Saw.ar(pitch, mul:env)]);
	panner = Pan2.ar(sin, 0);
	Out.ar(0, panner);
}).send(s);
)

(
var scale, synth, duration=0.2, step=0, playNote, freq=220, a=0.1, d=0.7, s=0.9, r=0.5, slew=0, oscillator=0,
octave = [1, 1, 1, 1, 1, 1, 1, 1],
amp = [1, 1, 1, 1, 1, 1, 1, 1],
base = 2**(1/12),
// MODES
jonian = [1, base**2, base**4, base**5, base**7, base**9, base**11, 2],
dorian = [1, base**2, base**3, base**5, base**7, base**9, base**10, 2],
phrygian = [1, base**1, base**3, base**5, base**7, base**8, base**10, 2],
lydian = [1, base**2, base**4, base**6, base**7, base**9, base**11, 2],
mixolydian = [1, base**2, base**4, base**5, base**7, base**9, base**10, 2],
aeolian = [1, base**2, base**3, base**5, base**7, base**8, base**10, 2],
locrian = [1, base**1, base**3, base**5, base**6, base**8, base**10, 2];
synth = Synth.new("RTISynth");

scale = jonian;

///////////////////
// Page 1 controls
///////////////////
OSCdef.new(\sinewave,
	{
		arg msg, time, addr, recvPort;
		[msg, time, addr, recvPort].postln;
		if(msg[1] == 1,
			{
				oscillator = 0;
			}
		);
	},
	'/1/oscillator/1/1'
);

OSCdef.new(\pulse,
	{
		arg msg, time, addr, recvPort;
		[msg, time, addr, recvPort].postln;
		if(msg[1] == 1,
			{
				oscillator = 1;
			}
		);
	},
	'/1/oscillator/1/2'
);

OSCdef.new(\sawtooth,
	{
		arg msg, time, addr, recvPort;
		[msg, time, addr, recvPort].postln;
		if(msg[1] == 1,
			{
				oscillator = 2;
			}
		);
	},
	'/1/oscillator/1/3'
);

OSCdef.new(\slew,
	{
		arg msg, time, addr, recvPort;
		[msg, time, addr, recvPort].postln;
		slew = msg[1];
	},
	'/1/slew'
);

//////////////////
// Page 2 controls
//////////////////

OSCdef.new(\jonian,
	{
		arg msg, time, addr, recvPort;
		[msg, time, addr, recvPort].postln;
		if(msg[1] == 1,
			{
				scale = jonian.scramble;
			}
		);
	},
	'/3/scale/1/1'
);

OSCdef.new(\dorian,
	{
		arg msg, time, addr, recvPort;
		[msg, time, addr, recvPort].postln;
		if(msg[1] == 1,
			{
				scale = dorian.scramble;
			}
		);
	},
	'/3/scale/1/2'
);

OSCdef.new(\phrygian,
	{
		arg msg, time, addr, recvPort;
		[msg, time, addr, recvPort].postln;
		if(msg[1] == 1,
			{
				scale = phrygian.scramble;
			}
		);
	},
	'/3/scale/1/3'
);

OSCdef.new(\lydian,
	{
		arg msg, time, addr, recvPort;
		[msg, time, addr, recvPort].postln;
		if(msg[1] == 1,
			{
				scale = lydian.scramble;
			}
		);
	},
	'/3/scale/1/4'
);

OSCdef.new(\mixolydian,
	{
		arg msg, time, addr, recvPort;
		[msg, time, addr, recvPort].postln;
		if(msg[1] == 1,
			{
				scale = mixolydian.scramble;
			}
		);
	},
	'/3/scale/1/5'
);

OSCdef.new(\aeolian,
	{
		arg msg, time, addr, recvPort;
		[msg, time, addr, recvPort].postln;
		if(msg[1] == 1,
			{
				scale = aeolian.scramble;
			}
		);
	},
	'/3/scale/1/6'
);

OSCdef.new(\locrian,
	{
		arg msg, time, addr, recvPort;
		[msg, time, addr, recvPort].postln;
		if(msg[1] == 1,
			{
				scale = locrian.scramble;
			}
		);
	},
	'/3/scale/1/7'
);

playNote = {
	arg repeats = 8;
	Routine.new({
		repeats.do({
			var pitch;
			pitch = (freq * scale[step] * (2**octave[step]));
			synth.set(\freq, pitch, \amp, amp[step], \gate, 1, \a, a, \d, d, \s, s, \r, r, \slew, slew, \osctype, oscillator);
			duration.wait;
			synth.set(\gate, 0.0);
			step = (step+1)%8;
		});
	});
};

playNote.value(inf).play;
)

(
OSCFunc.trace(true);
NetAddr.langPort;
)