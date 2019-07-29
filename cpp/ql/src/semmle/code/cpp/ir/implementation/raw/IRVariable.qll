private import internal.IRInternal
import IRFunction
private import internal.IRVariableImports as Imports
import Imports::TempVariableTag
private import Imports::IRUtilities
private import Imports::TTempVariableTag
private import Imports::TIRVariable

IRUserVariable getIRUserVariable(Language::Function func, Language::Variable var) {
  result.getVariable() = var and
  result.getEnclosingFunction() = func
}

/**
 * Represents a variable referenced by the IR for a function. The variable may
 * be a user-declared variable (`IRUserVariable`) or a temporary variable
 * generated by the AST-to-IR translation (`IRTempVariable`).
 */
abstract class IRVariable extends TIRVariable {
  Language::Function func;

  abstract string toString();

  /**
   * Gets the type of the variable.
   */
  abstract Language::Type getType();

  /**
   * Gets the AST node that declared this variable, or that introduced this
   * variable as part of the AST-to-IR translation.
   */
  abstract Language::AST getAST();

  /**
   * Gets an identifier string for the variable. This identifier is unique
   * within the function.
   */
  abstract string getUniqueId();
  
  /**
   * Gets the source location of this variable.
   */
  final Language::Location getLocation() {
    result = getAST().getLocation()
  }

  /**
   * Gets the IR for the function that references this variable.
   */
  final IRFunction getEnclosingIRFunction() {
    result.getFunction() = func
  }

  /**
   * Gets the function that references this variable.
   */
  final Language::Function getEnclosingFunction() {
    result = func
  }
}

/**
 * Represents a user-declared variable referenced by the IR for a function.
 */
class IRUserVariable extends IRVariable, TIRUserVariable {
  Language::Variable var;
  Language::Type type;

  IRUserVariable() {
    this = TIRUserVariable(var, type, func)
  }

  override final string toString() {
    result = getVariable().toString()
  }

  override final Language::AST getAST() {
    result = var
  }

  override final string getUniqueId() {
    result = getVariable().toString() + " " + getVariable().getLocation().toString()
  }

  override final Language::Type getType() {
    result = type
  }

  /**
   * Gets the original user-declared variable.
   */
  Language::Variable getVariable() {
    result = var
  }
}

/**
 * Represents a variable (user-declared or temporary) that is allocated on the
 * stack. This includes all parameters, non-static local variables, and
 * temporary variables.
 */
abstract class IRAutomaticVariable extends IRVariable {
}

class IRAutomaticUserVariable extends IRUserVariable, IRAutomaticVariable {
  override Language::AutomaticVariable var;

  IRAutomaticUserVariable() {
    Language::isVariableAutomatic(var)
  }

  final override Language::AutomaticVariable getVariable() {
    result = var
  }
}

class IRStaticUserVariable extends IRUserVariable {
  override Language::StaticVariable var;

  IRStaticUserVariable() {
    not Language::isVariableAutomatic(var)
  }

  final override Language::StaticVariable getVariable() {
    result = var
  }
}

IRTempVariable getIRTempVariable(Language::AST ast, TempVariableTag tag) {
  result.getAST() = ast and
  result.getTag() = tag
}

class IRTempVariable extends IRVariable, IRAutomaticVariable, TIRTempVariable {
  Language::AST ast;
  TempVariableTag tag;
  Language::Type type;

  IRTempVariable() {
    this = TIRTempVariable(func, ast, tag, type)
  }

  override final Language::Type getType() {
    result = type
  }

  override final Language::AST getAST() {
    result = ast
  }

  override final string getUniqueId() {
    result = "Temp: " + Construction::getTempVariableUniqueId(this)
  }

  final TempVariableTag getTag() {
    result = tag
  }

  override string toString() {
    result = getBaseString() + ast.getLocation().getStartLine().toString() + ":" +
      ast.getLocation().getStartColumn().toString()
  }

  string getBaseString() {
    result = "#temp"
  }
}

class IRReturnVariable extends IRTempVariable {
  IRReturnVariable() {
    tag = ReturnValueTempVar()
  }

  override final string toString() {
    result = "#return"
  }
}

class IRThrowVariable extends IRTempVariable {
  IRThrowVariable() {
    tag = ThrowTempVar()
  }

  override string getBaseString() {
    result = "#throw"
  }
}
