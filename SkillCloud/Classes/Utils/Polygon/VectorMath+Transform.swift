import Foundation

/// Radian defined as Float
public typealias Radian = Float
/// Degrees defined as Float
public typealias Degree = Float

public extension Degree {
    /// Converts radians to degrees
    public var radians: Radian { return self / 180 * .pi }
}

public extension Radian {
    /// Converts degrees to radians
    public var degrees: Float { return self / .pi * 180 }
}

// MARK: - Transform
/// General transform description, defining position (as translation) in parent coordinate space
/// scale as scale along local __x,y,z__ axis, and rotation as rotation as Vector4 (x,y,z,w):
///  * clockwise with __w__ degrees around rotation vector defined as __x,y,z__
public struct Transform {
    // MARK: - Properties
    /// Position (as translation from 0,0,0 in parent coordinate space)
    public var position: Vector3
    /// Rotation as rotation as Vector4 (x,y,z,w) - clockwise with __w__ degrees around rotation vector defined as __x,y,z__
    public var rotation: RotationVector4
    /// Scale as scale along local __x,y,z__ axis
    public var scale: Vector3
    
    /// Transfor identity - no translation, no rotation, scale uniform (1,1,1)
    public static var identity: Transform { return Transform(position: Vector3.zero, rotation: RotationVector4.zero, scale: Vector3.uniform) }
    
    // MARK: - Initializers
    /// Initializes new __Transform__ instance with given values:
    ///
    /// - Parameters:
    ///   - position: Position (as translation from 0,0,0 in parent coordinate space)
    ///   - rotation: Rotation as rotation as Vector4 (x,y,z,w) - clockwise with __w__ degrees around rotation vector defined as __x,y,z__
    ///   - scale: Scale as scale along local __x,y,z__ axis
    public init(position: Vector3, rotation: RotationVector4, scale: Vector3) {
        self.position = position
        self.rotation = rotation
        self.scale = scale
    }
}

public extension Transform {
    public static var zero: Transform { return Transform(position: .zero, rotation: .zero, scale: .uniform) }
}

// MARK: - Rotation Vector
/// Rotation vector is vector, where __x,y,z__ components define rotation vector, and __w__ component 
/// (in degrees) defines clockwise rotation around that vector.
public struct RotationVector4 {
    public var x: Scalar
    public var y: Scalar
    public var z: Scalar
    public var w: Degree
}

public extension RotationVector4 {
    /// Vector for no rotation at all
    public static var zero: RotationVector4 { return RotationVector4(x: 0, y: 0, z: 0, w: 0) }
    
    /// Initializes new __RotationVector4__ instance with given values:
    ///
    /// - Parameters:
    ///   - x: RotationVector3 x component
    ///   - y: RotationVector3 y component
    ///   - z: RotationVector3 z component
    ///   - w: Rotation clockwise around RotationVector3 (in degrees)
    public init(_ x: Scalar, _ y: Scalar, _ z: Scalar, _ w: Degree) {
        self.init(x: x, y: y, z: z, w: w)
    }
    
}

// MARK: - VectorMath extensions
extension Vector3 {
    /// Returns uniform vector (all components equals 1)
    public static var uniform: Vector3 { return Vector3(x: 1, y: 1, z: 1) }
}

extension Vector4 {
    /// Returns uniform vector (all components equals 1)
    public static var uniform: Vector4 { return Vector4(x: 1, y: 1, z: 1, w: 1) }
}

