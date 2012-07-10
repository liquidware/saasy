# -*- encoding : utf-8 -*-
module Rails
  class Svn < Scm
    def self.checkout(repos, branch = nil)
      `svn checkout #{repos}/#{branch || "trunk"}`
    end
  end
end
