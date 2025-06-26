import type { FastifyInstance } from "fastify";

export async function healthCheckRoute(app: FastifyInstance) {
  app.get('/health', async (request, reply) => {
    await reply.status(201).send({ message: 'OK!' })
  })
}