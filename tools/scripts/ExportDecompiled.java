// Decompiles every function of the current program and writes them to <outdir>/<program>.c,
// plus <program>.symbols.txt (exports, imports, strings with xrefs).
// Usage (headless): -postScript ExportDecompiled.java <outdir>
import ghidra.app.decompiler.DecompInterface;
import ghidra.app.decompiler.DecompileOptions;
import ghidra.app.decompiler.DecompileResults;
import ghidra.app.script.GhidraScript;
import ghidra.program.model.address.Address;
import ghidra.program.model.listing.Data;
import ghidra.program.model.listing.DataIterator;
import ghidra.program.model.listing.Function;
import ghidra.program.model.listing.FunctionIterator;
import ghidra.program.model.symbol.Reference;
import ghidra.program.model.symbol.Symbol;
import ghidra.program.model.symbol.SymbolIterator;

import java.io.File;
import java.io.PrintWriter;

public class ExportDecompiled extends GhidraScript {
	@Override
	protected void run() throws Exception {
		String[] args = getScriptArgs();
		File outDir = new File(args.length > 0 ? args[0] : ".");
		outDir.mkdirs();
		String name = currentProgram.getName();

		DecompInterface ifc = new DecompInterface();
		ifc.setOptions(new DecompileOptions());
		ifc.toggleCCode(true);
		ifc.toggleSyntaxTree(false);
		ifc.openProgram(currentProgram);

		int total = currentProgram.getFunctionManager().getFunctionCount();
		int done = 0, failed = 0;
		try (PrintWriter out = new PrintWriter(new File(outDir, name + ".c"), "UTF-8")) {
			out.printf("// Decompiled by Ghidra from %s (%d functions)%n%n", name, total);
			FunctionIterator it = currentProgram.getFunctionManager().getFunctions(true);
			while (it.hasNext() && !monitor.isCancelled()) {
				Function f = it.next();
				if (f.isThunk() || f.isExternal()) continue;
				DecompileResults r = ifc.decompileFunction(f, 60, monitor);
				out.printf("// ===== %s @ %s =====%n", f.getName(true), f.getEntryPoint());
				if (r != null && r.decompileCompleted()) {
					out.println(r.getDecompiledFunction().getC());
				} else {
					failed++;
					out.printf("// decompilation failed: %s%n%n", r == null ? "null" : r.getErrorMessage());
				}
				if (++done % 500 == 0) println(name + ": " + done + "/" + total);
			}
		}
		ifc.dispose();

		try (PrintWriter out = new PrintWriter(new File(outDir, name + ".symbols.txt"), "UTF-8")) {
			out.println("## EXPORTS");
			for (Address a : currentProgram.getSymbolTable().getExternalEntryPointIterator()) {
				Symbol s = currentProgram.getSymbolTable().getPrimarySymbol(a);
				out.printf("%s %s%n", a, s == null ? "?" : s.getName());
			}
			out.println("\n## IMPORTS");
			for (Symbol s : currentProgram.getSymbolTable().getExternalSymbols()) {
				out.printf("%s::%s%n", s.getParentNamespace().getName(), s.getName());
			}
			out.println("\n## STRINGS (address | referencing functions | value)");
			DataIterator di = currentProgram.getListing().getDefinedData(true);
			while (di.hasNext()) {
				Data d = di.next();
				if (!d.hasStringValue()) continue;
				StringBuilder refs = new StringBuilder();
				for (Reference ref : getReferencesTo(d.getAddress())) {
					Function f = getFunctionContaining(ref.getFromAddress());
					if (f != null) refs.append(f.getName()).append(',');
				}
				out.printf("%s | %s | %s%n", d.getAddress(), refs, d.getDefaultValueRepresentation());
			}
		}
		println(String.format("%s: %d functions exported, %d failed -> %s", name, done, failed, outDir));
	}
}
