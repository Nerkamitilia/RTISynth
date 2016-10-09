// Nestor Napoles Lopez, 2016

(
SynthDef.new("RTISynth", {
	arg freq, amp, gate, a, d, s, r, slew, osctype, lpfilter, hpfilter;
	var env, sin, pitch, panner, filter1, filter2;
	env = EnvGen.ar(Env([a, d, s, r]));
	// Adding Slew if selected
	pitch = Select.kr(slew, [freq, Slew.kr(freq, 4000, 4000)]);
	// Using the right oscillator
	sin = Select.ar(osctype, [SinOsc.ar(pitch, mul:env*amp), LFPulse.ar(pitch, mul:env*amp), Saw.ar(pitch, mul:env*amp)]);
	filter1 = Select.ar(lpfilter, [sin, RLPF.ar(sin)]);
	filter2 = Select.ar(hpfilter, [filter1, RHPF.ar(sin, 880)]);
	panner = Pan2.ar(filter2, 0);
	Out.ar(0, panner);
}).send(s);
)

(
var scale, synth, duration=0.2, step=0, playNote, freq=220, a=0.82, d=0.06, s=0.72, r=0.5,
slew=0, oscillator=0, lpfilter=0, hpfilter=0, accelvalue=0, acceltoggle=0,
octave = [0, 0, 0, 0, 0, 0, 0, 0],
amp = [1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0],
unmute = [1, 1, 1, 1, 1, 1, 1, 1],
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

OSCdef.new(\attack,
	{
		arg msg, time, addr, recvPort;
		[msg, time, addr, recvPort].postln;
		a = msg[1];
		a.postln;
	},
	'/1/attack'
);

OSCdef.new(\decay,
	{
		arg msg, time, addr, recvPort;
		[msg, time, addr, recvPort].postln;
		d = msg[1];
		d.postln;
	},
	'/1/decay'
);

OSCdef.new(\sustain,
	{
		arg msg, time, addr, recvPort;
		[msg, time, addr, recvPort].postln;
		s = msg[1];
		s.postln;
	},
	'/1/sustain'
);

OSCdef.new(\release,
	{
		arg msg, time, addr, recvPort;
		[msg, time, addr, recvPort].postln;
		r = msg[1];
		r.postln;
	},
	'/1/release'
);

OSCdef.new(\tempo,
	{
		arg msg, time, addr, recvPort;
		[msg, time, addr, recvPort].postln;
		duration = msg[1];
	},
	'/1/tempo'
);

OSCdef.new(\tempo,
	{
		arg msg, time, addr, recvPort;
		[msg, time, addr, recvPort].postln;
		duration = msg[1];
	},
	'/1/tempo'
);

OSCdef.new(\lpfilter,
	{
		arg msg, time, addr, recvPort;
		[msg, time, addr, recvPort].postln;
		lpfilter = msg[1];
	},
	'/1/filters/1/1'
);

OSCdef.new(\hpfilter,
	{
		arg msg, time, addr, recvPort;
		[msg, time, addr, recvPort].postln;
		hpfilter = msg[1];
	},
	'/1/filters/1/2'
);

OSCdef.new(\accelerometertoggle,
	{
		arg msg, time, addr, recvPort;
		[msg, time, addr, recvPort].postln;
		acceltoggle = msg[1];
	},
	'/1/accelerometer'
);

OSCdef.new(\accelerometervalue,
	{
		arg msg, time, addr, recvPort;
		accelvalue = msg[2];
	},
	'/accxyz'
);

//////////////////
// Page 2 controls
//////////////////

// Amplitude faders
OSCdef.new(\amp1,
	{
		arg msg, time, addr, recvPort;
		[msg, time, addr, recvPort].postln;
		amp[0] = msg[1];
	},
	'/2/fader1'
);
OSCdef.new(\amp2,
	{
		arg msg, time, addr, recvPort;
		[msg, time, addr, recvPort].postln;
		amp[1] = msg[1];
	},
	'/2/fader2'
);
OSCdef.new(\amp3,
	{
		arg msg, time, addr, recvPort;
		[msg, time, addr, recvPort].postln;
		amp[2] = msg[1];
	},
	'/2/fader3'
);
OSCdef.new(\amp4,
	{
		arg msg, time, addr, recvPort;
		[msg, time, addr, recvPort].postln;
		amp[3] = msg[1];
	},
	'/2/fader4'
);
OSCdef.new(\amp5,
	{
		arg msg, time, addr, recvPort;
		[msg, time, addr, recvPort].postln;
		amp[4] = msg[1];
	},
	'/2/fader5'
);
OSCdef.new(\amp6,
	{
		arg msg, time, addr, recvPort;
		[msg, time, addr, recvPort].postln;
		amp[5] = msg[1];
	},
	'/2/fader6'
);
OSCdef.new(\amp7,
	{
		arg msg, time, addr, recvPort;
		[msg, time, addr, recvPort].postln;
		amp[6] = msg[1];
	},
	'/2/fader7'
);
OSCdef.new(\amp8,
	{
		arg msg, time, addr, recvPort;
		[msg, time, addr, recvPort].postln;
		amp[7] = msg[1];
	},
	'/2/fader8'
);


// MUTE Toggles
OSCdef.new(\mute1,
	{
		arg msg, time, addr, recvPort;
		unmute[0] = msg[1];
	},
	'/2/toggle1'
);
OSCdef.new(\mute2,
	{
		arg msg, time, addr, recvPort;
		unmute[1] = msg[1];
	},
	'/2/toggle2'
);
OSCdef.new(\mute3,
	{
		arg msg, time, addr, recvPort;
		unmute[2] = msg[1];
	},
	'/2/toggle3'
);
OSCdef.new(\mute4,
	{
		arg msg, time, addr, recvPort;
		unmute[3] = msg[1];
	},
	'/2/toggle4'
);
OSCdef.new(\mute5,
	{
		arg msg, time, addr, recvPort;
		unmute[4] = msg[1];
	},
	'/2/toggle5'
);
OSCdef.new(\mute6,
	{
		arg msg, time, addr, recvPort;
		unmute[5] = msg[1];
	},
	'/2/toggle6'
);
OSCdef.new(\mute7,
	{
		arg msg, time, addr, recvPort;
		unmute[6] = msg[1];
	},
	'/2/toggle7'
);
OSCdef.new(\mute8,
	{
		arg msg, time, addr, recvPort;
		unmute[7] = msg[1];
	},
	'/2/toggle8'
);

//////////////////
// Page 3 controls
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

OSCdef.new(\oct0m2,
	{
		octave[0] = -2;
	},
	'/3/multitoggle1/1/1'
);

// First step octave
OSCdef.new(\oct0m1,
	{
		octave[0] = -1;
	},
	'/3/multitoggle1/2/1'
);

OSCdef.new(\oct0z,
	{
		octave[0] = 0;
	},
	'/3/multitoggle1/3/1'
);

OSCdef.new(\oct0p1,
	{
		octave[0] = 1;
	},
	'/3/multitoggle1/4/1'
);

OSCdef.new(\oct0p2,
	{
		octave[0] = 2;
	},
	'/3/multitoggle1/5/1'
);

// Second step octave
OSCdef.new(\oct1m2,
	{
		octave[1] = -2;
	},
	'/3/multitoggle2/1/1'
);

OSCdef.new(\oct1m1,
	{
		octave[1] = -1;
	},
	'/3/multitoggle2/2/1'
);

OSCdef.new(\oct1z,
	{
		octave[1] = 0;
	},
	'/3/multitoggle2/3/1'
);

OSCdef.new(\oct1p1,
	{
		octave[1] = 1;
	},
	'/3/multitoggle2/4/1'
);

OSCdef.new(\oct1p2,
	{
		octave[1] = 2;
	},
	'/3/multitoggle2/5/1'
);

// Third step octave
OSCdef.new(\oct2m2,
	{
		octave[2] = -2;
	},
	'/3/multitoggle3/1/1'
);

OSCdef.new(\oct2m1,
	{
		octave[2] = -1;
	},
	'/3/multitoggle3/2/1'
);

OSCdef.new(\oct2z,
	{
		octave[2] = 0;
	},
	'/3/multitoggle3/3/1'
);

OSCdef.new(\oct2p1,
	{
		octave[2] = 1;
	},
	'/3/multitoggle3/4/1'
);

OSCdef.new(\oct2p2,
	{
		octave[2] = 2;
	},
	'/3/multitoggle3/5/1'
);

// Fourth step octave
OSCdef.new(\oct3m2,
	{
		octave[3] = -2;
	},
	'/3/multitoggle4/1/1'
);

OSCdef.new(\oct3m1,
	{
		octave[3] = -1;
	},
	'/3/multitoggle4/2/1'
);

OSCdef.new(\oct3z,
	{
		octave[3] = 0;
	},
	'/3/multitoggle4/3/1'
);

OSCdef.new(\oct3p1,
	{
		octave[3] = 1;
	},
	'/3/multitoggle4/4/1'
);

OSCdef.new(\oct3p2,
	{
		octave[3] = 2;
	},
	'/3/multitoggle4/5/1'
);

// Fifth step octave
OSCdef.new(\oct4m2,
	{
		octave[4] = -2;
	},
	'/3/multitoggle5/1/1'
);

OSCdef.new(\oct4m1,
	{
		octave[4] = -1;
	},
	'/3/multitoggle5/2/1'
);

OSCdef.new(\oct4z,
	{
		octave[4] = 0;
	},
	'/3/multitoggle5/3/1'
);

OSCdef.new(\oct4p1,
	{
		octave[4] = 1;
	},
	'/3/multitoggle5/4/1'
);

OSCdef.new(\oct4p2,
	{
		octave[4] = 2;
	},
	'/3/multitoggle5/5/1'
);

// Sixth step octave
OSCdef.new(\oct5m2,
	{
		octave[5] = -2;
	},
	'/3/multitoggle6/1/1'
);

OSCdef.new(\oct5m1,
	{
		octave[5] = -1;
	},
	'/3/multitoggle6/2/1'
);

OSCdef.new(\oct5z,
	{
		octave[5] = 0;
	},
	'/3/multitoggle6/3/1'
);

OSCdef.new(\oct5p1,
	{
		octave[5] = 1;
	},
	'/3/multitoggle6/4/1'
);

OSCdef.new(\oct5p2,
	{
		octave[5] = 2;
	},
	'/3/multitoggle6/5/1'
);

// Seventh step octave
OSCdef.new(\oct6m2,
	{
		octave[6] = -2;
	},
	'/3/multitoggle7/1/1'
);

OSCdef.new(\oct6m1,
	{
		octave[6] = -1;
	},
	'/3/multitoggle7/2/1'
);

OSCdef.new(\oct6z,
	{
		octave[6] = 0;
	},
	'/3/multitoggle7/3/1'
);

OSCdef.new(\oct6p1,
	{
		octave[6] = 1;
	},
	'/3/multitoggle7/4/1'
);

OSCdef.new(\oct6p2,
	{
		octave[6] = 2;
	},
	'/3/multitoggle7/5/1'
);

// Eight step octave
OSCdef.new(\oct7m2,
	{
		octave[7] = -2;
	},
	'/3/multitoggle8/1/1'
);

OSCdef.new(\oct7m1,
	{
		octave[7] = -1;
	},
	'/3/multitoggle8/2/1'
);

OSCdef.new(\oct7z,
	{
		octave[7] = 0;
	},
	'/3/multitoggle8/3/1'
);

OSCdef.new(\oct7p1,
	{
		octave[7] = 1;
	},
	'/3/multitoggle8/4/1'
);

OSCdef.new(\oct7p2,
	{
		octave[7] = 2;
	},
	'/3/multitoggle8/5/1'
);

playNote = {
	arg repeats = 8;
	Routine.new({
		repeats.do({
			var pitch;
			if(acceltoggle == 1,
				{
					freq = 440 * (2**(accelvalue/5));
				}
			);
			freq.postln;
			pitch = (freq * scale[step] * (2**octave[step]));
			synth.set(\freq, pitch, \amp, amp[step]*unmute[step], \gate, 1, \a, a, \d, d, \s, s, \r, r, \slew, slew, \osctype, oscillator, \lpfilter, lpfilter, \hpfilter, hpfilter);
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