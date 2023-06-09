class String
  def unescape_trademarks
    trademark_r = '<sup><small>®</small></sup>'
    trademark_tm = '<sup><small>™</small></sup>'

    outstring = gsub('__TRADEMARK-R__', trademark_r).gsub('__TRADEMARK-TM__', trademark_tm)
    outstring
  end
end
