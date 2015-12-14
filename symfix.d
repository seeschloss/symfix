import std.string;
import std.array;
import std.cstream;

extern(C)
	{
	int symlink(immutable(char) *oldpath, immutable(char) *newpath);
	int readlink(immutable(char) *path, char *buf, int bufsiz);
	int unlink(immutable(char) *path);
	}

bool _symlink(char[] from, char[] to)
	{
	return symlink(toStringz(from), toStringz(to)) == 0;
	}

char[] _readlink(char[] path)
	{
	char[512] buf;
	int l = readlink(toStringz(path), buf.ptr, buf.length);

	if (l >= 0)
		{
		return buf[0 .. l].dup;
		}
	else
		{
		return null;
		}
	}

bool _unlink(char[] path)
	{
	return unlink(toStringz(path)) == 0;
	}

bool replace(char[] from, char[] to, char[] link)
	{
	char[] target = _readlink(link);
	char[] new_target = std.array.replace(target, from, to);

	if (new_target != target)
		{
		dout.writef("%s: %s => %s...", link, target, new_target);
		bool result = _unlink(link);
		if (!result)
			{
			dout.writefln(" cannot modify link");
			return false;
			}

		_symlink(new_target, link);

		dout.writefln(" ok");
		
		return true;
		}
	else
		{
		dout.writefln ("%s: Nothing to do.", link);
		return false;
		}
	}

int main(char[][] args)
	{
	if (args.length < 2 || args[1] == "--help" || args[1] == "-h")
		{
		dout.writefln("Usage: %s FROM TO LINK...\n"
		              "Fix symbolic links by replacing FROM with TO in their target.\n"
			      "\n"
			      "\t--help\tdisplay this help and exit\n"
			      "\n"
			      "Report bugs to SeeSchloss <seeschloss@seos.fr>",
			      args[0]);
		return 0;
		}
	else
		{
		bool result = true;

		foreach (char[] link ; args[3 .. $])
			{
			replace(args[1], args[2], link);
			}

		return 0;
		}
	}
