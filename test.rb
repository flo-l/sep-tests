BINARY = './basic'
TESTCASES = 'testcases/'

def run_test(test_name)
  test_basepath = TESTCASES + test_name
  input_file_path = test_basepath + '.in'
  expected_file_path = test_basepath + '.ref'
  output_file_path = test_basepath + '.out'
  autosave_ref_path = test_basepath + '.save.ref'
  autosave_out_path = test_basepath + '.save.out'
  autosave_arg = ""

  cmd = "#{BINARY} < #{input_file_path} > #{output_file_path} #{autosave_arg}"
  if File.exist? autosave_ref_path
    cmd << " -s #{autosave_out_path}"
  end

  `#{cmd}`
  exit_code = $?

  if !exit_code.success?
    info = [
    "Exit code: #{exit_code.inspect}",
    "Output: #{`cat #{output_file_path}`}"
    ].join("\n")
    return ["ERROR", info]
  end

  # autosave check
  if File.exist? autosave_ref_path
    `cmp -s #{autosave_ref_path} #{autosave_out_path}`
    if !$?.success?
      diff = `diff -u #{autosave_ref_path} #{autosave_out_path}`
      return ["AUTOSAVE_ERROR", diff]
    end
  end

  # output check
  `cmp -s #{expected_file_path} #{output_file_path}`
  if !$?.success?
    diff = `diff -u #{expected_file_path} #{output_file_path}`
    ["ERROR", diff]
  else
    valgrind_cmd = 'valgrind --tool=memcheck --leak-check=full --show-leak-kinds=all --error-exitcode=1'
    `#{valgrind_cmd} #{cmd} 2>> #{TESTCASES}valgrind.log`

    if $?.success?
      ["OK"]
    else
      ["VALGRIND ERROR", `cat #{TESTCASES}valgrind.log`]
    end
  end
end

def test_with_args(args, expected)
  cmd = [BINARY, args].join(' ')
  `#{cmd} < #{TESTCASES}quit.in > /dev/null`
  return_code = $?.exitstatus

  if return_code != expected
    puts "cmd_args ... [ERROR]"
    puts "#{cmd} => #{return_code}"
    puts "Output: #{`cat #{TESTCASES}quit.out`}"
    exit
  end
end

# preparation
`chmod 0444 #{TESTCASES}readonlyautosave.save.out`

# cmd tests
test_with_args "", 0
test_with_args "-s #{TESTCASES}valid.poke", 0
test_with_args "-m #{TESTCASES}valid.poke", 0
test_with_args "-s #{TESTCASES}valid.poke -m #{TESTCASES}valid.poke", 0

test_with_args "-m", 2
test_with_args "-s", 2
test_with_args "-m -s #{TESTCASES}valid.poke", 2
test_with_args "#{TESTCASES}valid.poke", 2
test_with_args "#{TESTCASES}valid.poke -m", 2

test_with_args "-s #{TESTCASES}valid.poke -m", 2
test_with_args "-s #{TESTCASES}valid.poke #{TESTCASES}valid.poke", 2
test_with_args "-s #{TESTCASES}valid.poke -m #{TESTCASES}valid.poke -m", 2
puts "cmd_args ... [OK]"

# run testcases
Dir["#{TESTCASES}*.in"].each do |input_file|
  test_name = File.basename(input_file, '.in')
  result, info = run_test(test_name)
  puts "#{test_name} ... [#{result}]"
  puts info.chomp if info && info != ""
end
