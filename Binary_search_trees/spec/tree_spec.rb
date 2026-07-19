require_relative 'spec_helper'

RSpec.describe Tree do
  let(:sorted_uniq) { [1, 3, 5, 7, 9, 11, 13, 15, 17, 19] }
  let(:tree) { Tree.new(sorted_uniq) }

  # ── Tree construction ──────────────────────────────────────────────

  describe '#initialize' do
    it 'builds a balanced tree from an array' do
      expect(tree).to be_balanced
    end

    it 'handles an empty array' do
      expect(Tree.new([]).root).to be_nil
    end

    it 'handles duplicates' do
      expect(Tree.new([5, 5, 5, 3, 3, 7, 7])).to be_balanced
    end

    it 'handles a single element' do
      t = Tree.new([42])
      expect(t.root.data).to eq(42)
      expect(t).to be_balanced
    end
  end

  # ── #include? ─────────────────────────────────────────────────────

  describe '#include?' do
    it 'returns true for values in the tree' do
      expect(tree.include?(7)).to be true
    end

    it 'returns false for values not in the tree' do
      expect(tree.include?(100)).to be false
    end

    it 'returns false for an empty tree' do
      expect(Tree.new([]).include?(5)).to be false
    end
  end

  # ── #insert ────────────────────────────────────────────────────────

  describe '#insert' do
    it 'adds a new value' do
      tree.insert(20)
      expect(tree.include?(20)).to be true
    end

    it 'handles duplicate values without error' do
      expect { tree.insert(7) }.not_to raise_error
      expect(tree.include?(7)).to be true
    end

    it 'unbalances the tree when many large values are inserted' do
      [100, 200, 300, 400].each { |n| tree.insert(n) }
      expect(tree).not_to be_balanced
    end
  end

  # ── #delete ────────────────────────────────────────────────────────

  describe '#delete' do
    it 'removes a leaf node' do
      tree.delete(19)
      expect(tree.include?(19)).to be false
    end

    it 'removes a node with one child' do
      tree.insert(20)
      tree.delete(20)
      expect(tree.include?(20)).to be false
    end

    it 'removes a node with two children' do
      tree.delete(15)
      expect(tree.include?(15)).to be false
    end

    it 'handles deleting the root' do
      mid = sorted_uniq[sorted_uniq.length / 2]
      tree.delete(mid)
      expect(tree.root).not_to be_nil
    end

    it 'does nothing for non-existent values' do
      expect { tree.delete(999) }.not_to raise_error
    end
  end

  # ── Traversals ─────────────────────────────────────────────────────

  describe '#level_order' do
    it 'returns an enumerator when no block given' do
      expect(tree.level_order).to be_a(Enumerator)
    end

    it 'yields all values' do
      result = []
      tree.level_order { |d| result << d }
      expect(result.sort).to eq(sorted_uniq)
    end
  end

  describe '#inorder' do
    it 'returns an enumerator when no block given' do
      expect(tree.inorder).to be_a(Enumerator)
    end

    it 'yields values in sorted order' do
      result = []
      tree.inorder { |d| result << d }
      expect(result).to eq(sorted_uniq)
    end
  end

  describe '#preorder' do
    it 'returns an enumerator when no block given' do
      expect(tree.preorder).to be_a(Enumerator)
    end

    it 'yields all values (root first)' do
      result = []
      tree.preorder { |d| result << d }
      expect(result.sort).to eq(sorted_uniq)
      expect(result.first).to eq(sorted_uniq[sorted_uniq.length / 2])
    end
  end

  describe '#postorder' do
    it 'returns an enumerator when no block given' do
      expect(tree.postorder).to be_a(Enumerator)
    end

    it 'yields all values' do
      result = []
      tree.postorder { |d| result << d }
      expect(result.sort).to eq(sorted_uniq)
    end
  end

  # ── #height ────────────────────────────────────────────────────────

  describe '#height' do
    it 'returns 0 for a leaf' do
      expect(tree.height(sorted_uniq.first)).to eq(0)
    end

    it 'returns a non-negative integer for the root' do
      h = tree.height(tree.root.data)
      expect(h).not_to be_nil
      expect(h).to be >= 0
    end

    it 'returns nil for a value not in the tree' do
      expect(tree.height(999)).to be_nil
    end
  end

  # ── #depth ─────────────────────────────────────────────────────────

  describe '#depth' do
    it 'returns 0 for the root' do
      expect(tree.depth(tree.root.data)).to eq(0)
    end

    it 'returns a positive integer for a leaf' do
      d = tree.depth(sorted_uniq.last)
      expect(d).to be > 0
    end

    it 'returns nil for a value not in the tree' do
      expect(tree.depth(999)).to be_nil
    end
  end

  # ── #balanced? / #rebalance ────────────────────────────────────────

  describe '#balanced?' do
    it 'returns true for a new tree' do
      expect(tree).to be_balanced
    end

    it 'returns false after unbalancing inserts' do
      4.times { tree.insert(100 + rand(1..100)) }
      expect(tree).not_to be_balanced
    end
  end

  describe '#rebalance' do
    it 'rebalances an unbalanced tree' do
      [100, 200, 300, 400].each { |n| tree.insert(n) }
      expect(tree).not_to be_balanced
      tree.rebalance
      expect(tree).to be_balanced
    end

    it 'is a no-op on an already balanced tree' do
      tree.rebalance
      expect(tree).to be_balanced
    end
  end

  # ── #pretty_print ──────────────────────────────────────────────────

  describe '#pretty_print' do
    it 'prints without raising' do
      expect { tree.pretty_print }.not_to raise_error
    end
  end

  # ── Integration ────────────────────────────────────────────────────

  describe 'integration — large random tree' do
    it 'builds, traverses, and rebalances without error' do
      arr = Array.new(100) { rand(1..1000) }
      t = Tree.new(arr)
      expect(t).to be_balanced

      %i[inorder preorder postorder level_order].each do |method|
        result = []
        t.public_send(method) { |d| result << d }
        expect(result.size).to eq(arr.sort.uniq.size)
      end

      [101, 105, 110, 120, 130, 150, 200, 250, 300].each { |n| t.insert(n) }
      t.rebalance
      expect(t).to be_balanced
    end
  end
end
