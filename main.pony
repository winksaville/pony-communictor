use "collections"

interface Communicator
	be send_to(dest: Communicator tag, data: String)
	be stop()

actor Actor is Communicator
	let _env: Env
	let _id: USize
	let _creator: Communicator tag
	let _out: StdStream
  var _running: Bool
	var _count: U64

	new create(env: Env, id: USize, creator: Communicator tag) =>
		env.out.print("Actor" + id.string() + "::create:+")
		_env = env
		_id = id
		_creator = creator
		_out = _env.out
		_running = true
		_count = 0
		_out.print("Actor" + id.string() + "::create:-")

	be send_to(dest: Communicator tag, data: String) =>
		_count = _count + 1
		_out.print("Actor" + _id.string() + "::send_to:+ _count=" + _count.string()
					      + " data=" + data)
		if _running then
			dest.send_to(this, "Actor" + _id.string() + "::send_to:  _count="
												+ _count.string())
		end
		_out.print("Actor" + _id.string() + "::send_to:- _count=" + _count.string()
					     + " data=" + data)

	be stop() =>
		_running = false
		_out.print("Actor" + _id.string() + "::stop:- _count=" + _count.string())

	fun ref enable_running() =>
		_running = true

actor Main is Communicator
	let _out: StdStream
	let _id: U64
	let _num_actors: USize
	var _actors: Array[Communicator tag]
  var _running: Bool
	var _count: USize
	var _max_count: USize

	new create(env: Env) =>
		env.out.print("Main::create:+")
		_id = 0
		_running = true
		_out = env.out
		_count = 0
		_max_count = 10

		_num_actors = 10
		_max_count = 10 * _num_actors

		_actors = Array[Communicator tag](_num_actors)
		for k in Range[USize](0, _num_actors) do
			_out.print("Main::create:  create Actor" + k.string())
			let a = Actor(env, k, this)
			_actors.push(a)
			a.send_to(this, "Main::create: first message to Actor" + k.string())
		end

		_out.print("Main::create:-")

	be send_to(dest: Communicator tag, data: String) =>
		_count = _count + 1
		_out.print("Main" + _id.string() + "::send_to:+ _count=" + _count.string()
					     + " data=" + data)
		if _count >= _max_count then
			dest.stop()
			if _running then _stop() end
		end
		if _running then
			dest.send_to(this, "Main::send_to:  _count=" + _count.string())
		end
		_out.print("Main" + _id.string() + "::send_to:- _count=" + _count.string()
					     + " data=" + data)

	be stop() =>
		_stop()

	// It's odd that functions in actors
	fun ref _stop() =>
		_running = false
		_out.print("Main" + _id.string() + "::stop:- _count=" + _count.string())
