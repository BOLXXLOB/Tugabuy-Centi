import { createClient } from 'redis';

let redisClient: ReturnType<typeof createClient>;

export async function connectToRedis(serverURL: string) {
  redisClient = createClient({
    url: serverURL,
  });

  redisClient.on('connect', () => {
    console.log(`REDIS - SUCCESS \t REDIS URL:\t ${serverURL}`.green);
  });

  redisClient.on('error', (error: any) => {
    console.error(`REDIS - ERROR \t REDIS URL:\t ${serverURL}\nError: ${error}`.red);
  });

  await redisClient.connect();
}

export { redisClient };
