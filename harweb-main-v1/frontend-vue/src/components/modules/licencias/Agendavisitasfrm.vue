<template>
  <div class="agenda-visitas-page">
    <nav aria-label="breadcrumb" class="mb-3">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Agenda de Visitas</li>
      </ol>
    </nav>
    <div class="card mb-3">
      <div class="card-header font-weight-bold">Agenda de Visitas</div>
      <div class="card-body">
        <form @submit.prevent="buscarVisitas" class="form-inline flex-wrap">
          <div class="form-group mr-3 mb-2">
            <label for="fechaIni" class="mr-2">Fecha inicio</label>
            <input type="date" v-model="filtros.fechaini" id="fechaIni" class="form-control" required />
          </div>
          <div class="form-group mr-3 mb-2">
            <label for="fechaFin" class="mr-2">al día</label>
            <input type="date" v-model="filtros.fechafin" id="fechaFin" class="form-control" required />
          </div>
          <div class="form-group mr-3 mb-2">
            <label for="dependencia" class="mr-2">Dependencia</label>
            <select v-model="filtros.id_dependencia" id="dependencia" class="form-control" required>
              <option value="" disabled>Seleccione...</option>
              <option v-for="dep in dependencias" :key="dep.id_dependencia" :value="dep.id_dependencia">
                {{ dep.descripcion }}
              </option>
            </select>
          </div>
          <button type="submit" class="btn btn-primary mb-2 mr-2">Buscar</button>
          <button type="button" class="btn btn-success mb-2 mr-2" @click="exportarExcel" :disabled="loading || visitas.length === 0">
            Exportar a Excel
          </button>
          <button type="button" class="btn btn-secondary mb-2" @click="imprimir" :disabled="visitas.length === 0">
            Imprimir
          </button>
        </form>
      </div>
    </div>
    
    <!-- Mostrar errores -->
    <div v-if="error" class="alert alert-danger">
      <i class="bi bi-exclamation-triangle"></i>
      {{ error }}
    </div>

    <div class="card">
      <div class="card-body p-0">
        <div v-if="loading" class="p-4 text-center">
          <div class="spinner-border"></div>
          <p class="mt-2">Cargando visitas agendadas...</p>
        </div>
        <div v-else>
          <table class="table table-bordered table-hover table-sm mb-0">
            <thead class="thead-light">
              <tr>
                <th>Fecha Visita</th>
                <th>Día</th>
                <th>Turno</th>
                <th>Hora</th>
                <th>Zona</th>
                <th>Subzona</th>
                <th>Folio</th>
                <th>Fecha Trámite</th>
                <th>Propietario</th>
                <th>Ubicación</th>
                <th>Actividad</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="row in visitas" :key="row.id_tramite + '-' + row.fecha">
                <td>{{ formatFecha(row.fecha) }}</td>
                <td>{{ row.dia_letras }}</td>
                <td>{{ row.turno }}</td>
                <td>{{ row.hora }}</td>
                <td>{{ row.zona }}</td>
                <td>{{ row.subzona }}</td>
                <td>{{ row.id_tramite }}</td>
                <td>{{ formatFecha(row.feccap) }}</td>
                <td>{{ row.propietarionvo || row.propietario }}</td>
                <td>{{ row.domcompleto }}</td>
                <td>{{ row.actividad }}</td>
              </tr>
              <tr v-if="!visitas.length">
                <td colspan="11" class="text-center">No hay datos para mostrar</td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>
    <!-- Modal de impresión -->
    <div ref="printArea" style="display:none">
      <h3 class="text-center">Reporte de Visitas Agendadas</h3>
      <p><strong>Dependencia:</strong> {{ dependenciaSeleccionadaDescripcion }}</p>
      <p><strong>Rango de fechas:</strong> {{ filtros.fechaini }} al {{ filtros.fechafin }}</p>
      <table border="1" cellspacing="0" cellpadding="2" style="width:100%;font-size:12px">
        <thead>
          <tr>
            <th>Fecha Visita</th>
            <th>Día</th>
            <th>Turno</th>
            <th>Hora</th>
            <th>Zona</th>
            <th>Subzona</th>
            <th>Folio</th>
            <th>Fecha Trámite</th>
            <th>Propietario</th>
            <th>Ubicación</th>
            <th>Actividad</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="row in visitas" :key="row.id_tramite + '-' + row.fecha">
            <td>{{ formatFecha(row.fecha) }}</td>
            <td>{{ row.dia_letras }}</td>
            <td>{{ row.turno }}</td>
            <td>{{ row.hora }}</td>
            <td>{{ row.zona }}</td>
            <td>{{ row.subzona }}</td>
            <td>{{ row.id_tramite }}</td>
            <td>{{ formatFecha(row.feccap) }}</td>
            <td>{{ row.propietarionvo || row.propietario }}</td>
            <td>{{ row.domcompleto }}</td>
            <td>{{ row.actividad }}</td>
          </tr>
        </tbody>
      </table>
    </div>
  </div>
</template>

<script>
export default {
  name: 'AgendaVisitasFrm',
  data() {
    const today = new Date().toISOString().substr(0, 10)
    return {
      loading: false,
      error: '',
      dependencias: [],
      visitas: [],
      filtros: {
        fechaini: today,
        fechafin: today,
        id_dependencia: ''
      }
    }
  },
  
  computed: {
    dependenciaSeleccionadaDescripcion() {
      const dep = this.dependencias.find(d => d.id_dependencia == this.filtros.id_dependencia)
      return dep ? dep.descripcion : ''
    }
  },
  
  mounted() {
    this.cargarDependencias()
  },
  
  methods: {

    async cargarDependencias() {
      try {
        const eRequest = {
          Operacion: 'sp_get_dependencias',
          Base: 'licencias',
          Parametros: [],
          Tenant: 'guadalajara'
        }

        const response = await this.$axios.post('/api/generic', {
          eRequest: eRequest
        })
        
        if (response.data.eResponse && response.data.eResponse.success && response.data.eResponse.data.result) {
          this.dependencias = response.data.eResponse.data.result
        } else {
          this.error = 'Error al cargar dependencias'
        }
      } catch (e) {
        console.error('Error cargando dependencias:', e)
        this.error = 'Error al cargar dependencias: ' + (e.message || 'Error desconocido')
      }
    },

    async buscarVisitas() {
      if (!this.filtros.id_dependencia || !this.filtros.fechaini || !this.filtros.fechafin) {
        this.error = 'Debe completar todos los campos de búsqueda'
        return
      }

      this.loading = true
      this.error = ''
      this.visitas = []

      try {
        const eRequest = {
          Operacion: 'sp_get_agenda_visitas',
          Base: 'licencias',
          Parametros: [
            {
              nombre: 'p_id_dependencia',
              valor: parseInt(this.filtros.id_dependencia),
              tipo: 'integer'
            },
            {
              nombre: 'p_fechaini',
              valor: this.filtros.fechaini,
              tipo: 'string'
            },
            {
              nombre: 'p_fechafin',
              valor: this.filtros.fechafin,
              tipo: 'string'
            }
          ],
          Tenant: 'guadalajara'
        }

        const response = await this.$axios.post('/api/generic', {
          eRequest: eRequest
        })
        
        if (response.data.eResponse && response.data.eResponse.success && response.data.eResponse.data.result) {
          this.visitas = response.data.eResponse.data.result
        } else {
          this.error = 'No se encontraron visitas para los criterios especificados'
        }
      } catch (e) {
        console.error('Error consultando visitas:', e)
        this.error = 'Error al consultar visitas: ' + (e.message || 'Error desconocido')
      } finally {
        this.loading = false
      }
    },

    exportarExcel() {
      // Exportar a Excel usando Blob y CSV
      if (!this.visitas.length) return
      const headers = [
        'Fecha Visita', 'Día', 'Turno', 'Hora', 'Zona', 'Subzona', 'Folio', 'Fecha Trámite', 'Propietario', 'Ubicación', 'Actividad'
      ]
      const rows = this.visitas.map(row => [
        this.formatFecha(row.fecha),
        row.dia_letras,
        row.turno,
        row.hora,
        row.zona,
        row.subzona,
        row.id_tramite,
        this.formatFecha(row.feccap),
        row.propietarionvo || row.propietario,
        row.domcompleto,
        row.actividad
      ])
      let csvContent = ''
      csvContent += headers.join(';') + '\n'
      rows.forEach(r => {
        csvContent += r.map(x => '"' + (x ? ('' + x).replace(/"/g, '""') : '') + '"').join(';') + '\n'
      })
      const blob = new Blob([csvContent], { type: 'text/csv;charset=utf-8;' })
      const link = document.createElement('a')
      link.href = URL.createObjectURL(blob)
      link.setAttribute('download', 'visitas_agendadas.csv')
      document.body.appendChild(link)
      link.click()
      document.body.removeChild(link)
    },

    imprimir() {
      // Imprimir usando ventana emergente
      const printContents = this.$refs.printArea.innerHTML
      const win = window.open('', '', 'width=900,height=700')
      win.document.write('<html><head><title>Reporte de Visitas Agendadas</title>')
      win.document.write('<style>table{border-collapse:collapse;}th,td{border:1px solid #333;padding:2px;}h3{text-align:center;}</style>')
      win.document.write('</head><body>' + printContents + '</body></html>')
      win.document.close()
      win.focus()
      setTimeout(() => {
        win.print()
        win.close()
      }, 500)
    },

    formatFecha(fecha) {
      if (!fecha) return ''
      try {
        // Manejar diferentes formatos de fecha
        const date = new Date(fecha)
        return date.toLocaleDateString('es-MX')
      } catch {
        // Si falla, intenta extraer solo la parte de fecha
        return fecha.toString().substr(0, 10)
      }
    }
  }
}
</script>

<style scoped>
.agenda-visitas-page {
  max-width: 1200px;
  margin: 0 auto;
}
.card {
  margin-bottom: 1rem;
}
.table th, .table td {
  font-size: 13px;
}
</style>
