import axios from 'axios'

const API_BASE_URL = '/api/v1'

class ProyectoService {
  async getAll() {
    const response = await axios.get(`${API_BASE_URL}/proyectos`)
    return response.data
  }

  async getById(id) {
    const response = await axios.get(`${API_BASE_URL}/proyectos/${id}`)
    return response.data
  }

  async create(data) {
    const response = await axios.post(`${API_BASE_URL}/proyectos`, data)
    return response.data
  }

  async update(id, data) {
    const response = await axios.put(`${API_BASE_URL}/proyectos/${id}`, data)
    return response.data
  }

  async delete(id) {
    const response = await axios.delete(`${API_BASE_URL}/proyectos/${id}`)
    return response.data
  }

  async getResumenAdeudos(id) {
    const response = await axios.get(`${API_BASE_URL}/proyectos/${id}/resumen-adeudos`)
    return response.data
  }

  async exportExcel() {
    const response = await axios.get(`${API_BASE_URL}/proyectos/export/excel`, {
      responseType: 'blob'
    })
    
    // Crear enlace de descarga
    const url = window.URL.createObjectURL(new Blob([response.data]))
    const link = document.createElement('a')
    link.href = url
    link.setAttribute('download', 'proyectos_pavimentacion.xlsx')
    document.body.appendChild(link)
    link.click()
    link.remove()
    window.URL.revokeObjectURL(url)
  }

  async getEstadisticas() {
    const response = await axios.get(`${API_BASE_URL}/estadisticas`)
    return response.data
  }

  async generatePDF(configuracion = {}) {
    const response = await axios.post(`${API_BASE_URL}/reportes/pdf`, configuracion, {
      responseType: 'blob'
    })
    
    // Crear enlace de descarga
    const url = window.URL.createObjectURL(new Blob([response.data]))
    const link = document.createElement('a')
    link.href = url
    link.setAttribute('download', 'reporte_pavimentacion.pdf')
    document.body.appendChild(link)
    link.click()
    link.remove()
    window.URL.revokeObjectURL(url)
  }
}

export const proyectoService = new ProyectoService()