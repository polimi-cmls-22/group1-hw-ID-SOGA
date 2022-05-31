(
/*
RUN THIS BLOCK
*/

s.reboot;

SynthDef(\harpacinosound, {
    | mix = 0.1, out = 0, amp = 1, freq = 440|
    var main, twang;
    main = SinOsc.ar(freq) * EnvGen.ar(Env.perc(0.03, 3.5 , 1, -7), doneAction: 2);
	main = HPF.ar( LPF.ar(main, 380), 120);
    twang = DynKlank.ar(`[
        [240*ExpRand(0.98, 1.02), 2020*ExpRand(0.98, 1.02), 3151*ExpRand(0.98, 1.02)],
        [-9, 0, -5].dbamp,  [0.8, 0.07, 0.08]], BPF.ar(PinkNoise.ar, 7000, 0.1) * EnvGen.ar(Env.perc(0.001, 0.01))) * 0.1;
	main = (main*mix) + (twang*(1-mix));
	main = Mix( main );
    Out.ar(out, 4*Pan2.ar(main, 0, amp));
}).add;

NetAddr("127.0.0.1", 57120);

~synth;
OSCdef('OSCreceiver',
	{
		arg msg;
		var frequency = msg[1];

		postln("freq: "+ frequency);

		~synth = Synth(\harpacinosound, [\freq, frequency]);
	},
	"/stringPlucked");
)





/*
OPTIONAL: SELECT A DIFFERENT OUTPUT (Asio doesn't glitch for me)
*/
ServerOptions.outDevices; // list output devices
Server.default.options.outDevice_("ASIO : ASIO4ALL v2");
Server.default.reboot;
Synth(\harpacinosound, [\freq, 440]); // test
