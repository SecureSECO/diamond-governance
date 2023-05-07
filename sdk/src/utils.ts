/**
 * @param arr Array to filter on
 * @param predicate Function to filter with
 * @returns {Promise<T[]>} Filtered array
 */
export async function asyncFilter<T>(arr : T[], predicate : ((elem : T) => Promise<boolean>)) {
    const results = await Promise.all(arr.map(predicate));

    return arr.filter((_v, index) => results[index]);
}

/**
 * @param arr Array to map on
 * @param func Function to map with
 * @returns {Promise<T2[]>} Mapped array
 */
export async function asyncMap<T1, T2>(arr : T1[], func : ((elem : T1) => Promise<T2>)) {
    return Promise.all(arr.map(func));
}

/**
 * @remarks 
 * 
 * Essentially returns a timestamp in seconds instead of milliseconds, because that's what the blockchain uses
 * 
 * @param date Date to convert
 * @returns {number} Timestamp in seconds
 */
export function ToBlockchainDate(date : Date) : number {
    return Math.round(date.getTime() / 1000);
}