/**
 * Status constants for user active state
 */
export const UserStatus = {
  ACTIVE: 1,
  INACTIVE: 0,
} as const;

/**
 * Convert boolean to database status value
 * @param isActive - Boolean value
 * @returns Database status value (1 or 0)
 */
export function booleanToStatus(isActive: boolean): number {
  return isActive ? UserStatus.ACTIVE : UserStatus.INACTIVE;
}

/**
 * Convert database status value to boolean
 * @param status - Database status value
 * @returns Boolean value
 */
export function statusToBoolean(status: number): boolean {
  return status === UserStatus.ACTIVE;
}

/**
 * Generate timestamp for API responses
 * @returns Current timestamp as string
 */
export function generateTimestamp(): string {
  return Date.now().toString();
}
