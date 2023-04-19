export async function asyncFilter<T>(arr : T[], predicate : ((elem : T) => Promise<boolean>)) {
    const results = await Promise.all(arr.map(predicate));

    return arr.filter((_v, index) => results[index]);
}

export async function asyncMap<T1, T2>(arr : T1[], func : ((elem : T1) => Promise<T2>)) {
    return Promise.all(arr.map(func));
}

export function ToBlockchainDate(date : Date) : number {
    return Math.round(date.getTime() / 1000);
}