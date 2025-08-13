import axios from 'axios'

const API_BASE_URL = '/api/v1'

class AdeudoService {
  async getByProyecto(idControl) {
    const response = await axios.get(`${API_BASE_URL}/adeudos/proyecto/${idControl}`)
    return response.data
  }

  async registrarPago(id, numeroRecibo) {
    const response = await axios.post(`${API_BASE_URL}/adeudos/${id}/pagar`, {
      numero_recibo: numeroRecibo
    })
    return response.data
  }
}

export const adeudoService = new AdeudoService()