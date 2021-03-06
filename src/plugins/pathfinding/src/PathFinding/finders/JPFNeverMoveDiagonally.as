package PathFinding.finders
{
	import PathFinding.core.DiagonalMovement;
	import PathFinding.core.Grid;
	import PathFinding.core.Node;
	
	/**
	 * ...
	 * @author ...
	 */
	public class JPFNeverMoveDiagonally extends JumpPointFinderBase
	{
		
		public function JPFNeverMoveDiagonally(opt:Object)
		{
			super(opt);
		
		}
		
		/**
		 * Search recursively in the direction (parent -> child), stopping only when a
		 * jump point is found.
		 * @protected
		 * @return {Array<Array<number>>} The x, y coordinate of the jump point
		 *     found, or null if not found
		 */
		override public function _jump(x:int, y:int, px:int, py:int):Array
		{
			var grid:Grid = this.grid, dx:int = x - px, dy:int = y - py;
			
			if (!grid.isWalkableAt(x, y))
			{
				return null;
			}
			
			if (this.trackJumpRecursion === true)
			{
				grid.getNodeAt(x, y).tested = true;
			}
			
			if (grid.getNodeAt(x, y) == this.endNode)
			{
				return [x, y];
			}
			
			if (dx !== 0)
			{
				if ((grid.isWalkableAt(x, y - 1) && !grid.isWalkableAt(x - dx, y - 1)) || (grid.isWalkableAt(x, y + 1) && !grid.isWalkableAt(x - dx, y + 1)))
				{
					return [x, y];
				}
			}
			else if (dy !== 0)
			{
				if ((grid.isWalkableAt(x - 1, y) && !grid.isWalkableAt(x - 1, y - dy)) || (grid.isWalkableAt(x + 1, y) && !grid.isWalkableAt(x + 1, y - dy)))
				{
					return [x, y];
				}
				//When moving vertically, must check for horizontal jump points
				if (this._jump(x + 1, y, x, y) || this._jump(x - 1, y, x, y))
				{
					return [x, y];
				}
			}
			else
			{
				throw new Error("Only horizontal and vertical movements are allowed");
			}
			
			return this._jump(x + dx, y + dy, x, y);
		}
		
		/**
		 * Find the neighbors for the given node. If the node has a parent,
		 * prune the neighbors based on the jump point search algorithm, otherwise
		 * return all available neighbors.
		 * @return {Array<Array<number>>} The neighbors found.
		 */
		override public function _findNeighbors(node:Node):Array
		{
			var parent:Node = node.parent, x:int = node.x, y:int = node.y, grid:Grid = this.grid, px:int, py:int, nx:int, ny:int, dx:int, dy:int, neighbors:Array = [], neighborNodes:Array, neighborNode:Node, i:int, l:int;
			
			// directed pruning: can ignore most neighbors, unless forced.
			if (parent)
			{
				px = parent.x;
				py = parent.y;
				// get the normalized direction of travel
				dx = (x - px) / Math.max(Math.abs(x - px), 1);
				dy = (y - py) / Math.max(Math.abs(y - py), 1);
				
				if (dx !== 0)
				{
					if (grid.isWalkableAt(x, y - 1))
					{
						neighbors.push([x, y - 1]);
					}
					if (grid.isWalkableAt(x, y + 1))
					{
						neighbors.push([x, y + 1]);
					}
					if (grid.isWalkableAt(x + dx, y))
					{
						neighbors.push([x + dx, y]);
					}
				}
				else if (dy !== 0)
				{
					if (grid.isWalkableAt(x - 1, y))
					{
						neighbors.push([x - 1, y]);
					}
					if (grid.isWalkableAt(x + 1, y))
					{
						neighbors.push([x + 1, y]);
					}
					if (grid.isWalkableAt(x, y + dy))
					{
						neighbors.push([x, y + dy]);
					}
				}
			}
			// return all neighbors
			else
			{
				neighborNodes = grid.getNeighbors(node, DiagonalMovement.Never);
				for (i = 0, l = neighborNodes.length; i < l; ++i)
				{
					neighborNode = neighborNodes[i];
					neighbors.push([neighborNode.x, neighborNode.y]);
				}
			}
			
			return neighbors;
		}
	}

}