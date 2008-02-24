package asunit.errors {
	
	public class AbstractMemberCalledError extends Error {
		
		public function AbstractMemberCalledError(message:String) {
			super(message);
			name = "AbstractMemberCalledError";
		}
	}
}