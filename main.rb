# state : integer(bit vector) representing possibility
# board : [state]
# width : integer
# height : interger
# relation : blank->0,circle->1,triangle->2,square->3

def read_input
  m,n = gets.split(",").map{|e| e.to_i}
  str = STDIN.readlines.map{|s| s.chomp}.join('')
  raise "invalid input" if str.length != m * n
  [m,n,str]
end

def make_board(input_board_str)
  input_board_str.split("").map do |c|
    case c
    when "B" then 15
    when "C" then 2
    when "T" then 4
    when "S" then 8
    else raise "unknown state"
    end
  end
end

# for debug
def board_to_str(board)
  t = {1 => "B", 2 => "C", 4 => "T", 8 => "S"}
  board.map do |i|
    str = ""
    [1,2,4,8].each do |flag|
      if i & flag == 0
        str += " "
      else
        str += t[flag]
      end
    end
    sprintf("(%s)", str)
  end
end


# board ->  bool
def check_row(board, i)
  # decide whether the i th row is palindrome,
  # where the row doesn't have any other candidate.
  def row_parindrome?(board, i)
    row = board[i*@n, @n]
    t = row.select{|e| e != 1}
    return t == t.reverse
  end

  def dfs(board, i, j)
    if j == @n
      return row_parindrome?(board, i)
    end
    idx = i*@n+j
    orig_state = board[idx]

    [1,2,4,8].each do |flag|
      if orig_state & flag != 0
        next_state = flag
        board[idx] = next_state
        r = dfs(board, i, j+1)
        board[idx] = orig_state
        return true if r
      end
    end

    return false
  end

  dfs(board, i, 0)
end

# board ->  bool
def check_col(board, j)
  # decide whether the i th column is palindrome,
  # where the column doesn't have any other candidate.
  def col_parindrome?(board, j)
    col = (0...@m).map{|i| board[i*@n+j]}
    t = col.select{|e| e != 1}
    return t == t.reverse
  end

  def dfs(board, i, j)
    if i == @m
      return col_parindrome?(board, j)
    end
    idx = i*@n+j
    orig_state = board[idx]

    [1,2,4,8].each do |flag|
      if orig_state & flag != 0
        next_state = flag
        board[idx] = next_state
        r = dfs(board, i+1, j)
        board[idx] = orig_state
        return true if r
      end
    end

    return false
  end

  dfs(board, 0, j)
end

# board -> new board
def reduce_candidates(board)
  r = []
  @m.times do |i|
    @n.times do |j|
      idx = i*@n + j
      orig_state = board[idx]
      cand = []
      [1,2,4,8].each do |flag|
        if flag & orig_state != 0
          board[idx] = flag
          if check_row(board, i) && check_col(board, j)
            cand << flag
          end
        end
      end
      board[idx] = orig_state
      next_state = cand.reduce(0){|acc,e| acc | e}
      r << next_state
    end
  end

  r
end

# board -> integer -> board array
def solve(board, idx, result)
  if idx == @m * @n
    @m.times do |i|
      return unless check_row(board, i)
    end
    @n.times do |j|
      return unless check_col(board, j)
    end
    result << Array.new(board)
    return
  end

  board_reduced = reduce_candidates(board)
  orig_state = board_reduced[idx]
  [1,2,4,8].each do |flag|
    if flag & orig_state != 0
      next_state = flag
      board_reduced[idx] = next_state
      solve(board_reduced, idx+1, result)
      board_reduced[idx] = orig_state
    end
  end
end

# board array -> ()
def display_result(result)
  if result.length > 0
    t = {1 => "B", 2 => "C", 4 => "T", 8 => "S"}
    char_seq = result[0].map{|e| t[e]}
    @m.times do |i|
      @n.times do |j|
        putc char_seq[i*@n+j]
      end
      puts ""
    end
  else
    puts "no result"
  end
end

@m,@n,input_board_str = read_input
init_board = make_board(input_board_str)
result = []
solve(init_board, 0, result)
display_result(result)
