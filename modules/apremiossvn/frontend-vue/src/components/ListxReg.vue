<template>
  <div class="list-reg-container">
    <div class="header-section">
      <h1 class="page-title">Listado por Registro</h1>
      <p class="page-subtitle">Consulta de registros por diferentes criterios</p>
    </div>

    <div class="search-section">
      <div class="search-form">
        <h2 class="section-title">Criterios de Búsqueda</h2>
        
        <div class="form-row">
          <div class="form-group">
            <label>Número de Registro:</label>
            <input 
              v-model="busqueda.numeroRegistro"
              type="text" 
              class="form-input"
              placeholder="Ingrese número de registro"
            />
          </div>
          
          <div class="form-group">
            <label>Fecha Desde:</label>
            <input 
              v-model="busqueda.fechaDesde"
              type="date" 
              class="form-input"
            />
          </div>
        </div>

        <div class="form-row">
          <div class="form-group">
            <label>Fecha Hasta:</label>
            <input 
              v-model="busqueda.fechaHasta"
              type="date" 
              class="form-input"
            />
          </div>
          
          <div class="form-group">
            <label>Estado:</label>
            <select v-model="busqueda.estado" class="form-select">
              <option value="">Todos los estados</option>
              <option value="activo">Activo</option>
              <option value="inactivo">Inactivo</option>
              <option value="pendiente">Pendiente</option>
            </select>
          </div>
        </div>

        <div class="form-actions">
          <button @click="buscarRegistros" :disabled="loading" class="btn btn-primary">
            {{ loading ? 'Buscando...' : 'Buscar' }}
          </button>
          <button @click="limpiarBusqueda" class="btn btn-secondary">Limpiar</button>
          <button @click="exportarExcel" class="btn btn-success">Exportar Excel</button>
        </div>
      </div>
    </div>

    <div v-if="registros.length > 0" class="results-section">
      <h2 class="section-title">Resultados ({{ registros.length }} registros)</h2>
      
      <div class="table-container">
        <table class="results-table">
          <thead>
            <tr>
              <th>No. Registro</th>
              <th>Fecha</th>
              <th>Descripción</th>
              <th>Estado</th>
              <th>Monto</th>
              <th>Acciones</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="registro in registros" :key="registro.id">
              <td>{{ registro.numero }}</td>
              <td>{{ formatearFecha(registro.fecha) }}</td>
              <td>{{ registro.descripcion }}</td>
              <td>
                <span :class="['estado', `estado-${registro.estado}`]">
                  {{ registro.estado }}
                </span>
              </td>
              <td>${{ formatearMonto(registro.monto) }}</td>
              <td>
                <button @click="verDetalle(registro)" class="btn-action btn-info">Ver</button>
                <button @click="editarRegistro(registro)" class="btn-action btn-warning">Editar</button>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>

    <div v-if="mensaje" class="mensaje" :class="tipoMensaje">
      {{ mensaje }}
    </div>
  </div>
</template>

<script>
export default {
  name: 'ListxReg',
  data() {
    return {
      loading: false,
      mensaje: '',
      tipoMensaje: '',
      busqueda: {
        numeroRegistro: '',
        fechaDesde: '',
        fechaHasta: '',
        estado: ''
      },
      registros: []
    }
  },
  methods: {
    async buscarRegistros() {
      if (!this.validarBusqueda()) {
        this.mostrarMensaje('Debe proporcionar al menos un criterio de búsqueda', 'error');
        return;
      }

      this.loading = true;
      this.registros = [];
      
      try {
        await new Promise(resolve => setTimeout(resolve, 1000));
        
        // Datos simulados
        this.registros = [
          {
            id: 1,
            numero: 'REG-2023-001',
            fecha: '2023-12-01',
            descripcion: 'Registro de multa por estacionamiento',
            estado: 'activo',
            monto: 500.00
          },
          {
            id: 2,
            numero: 'REG-2023-002', 
            fecha: '2023-11-28',
            descripcion: 'Registro de infracción menor',
            estado: 'pendiente',
            monto: 250.00
          }
        ];
        
        this.mostrarMensaje('Registros encontrados correctamente', 'success');
        
      } catch (error) {
        this.mostrarMensaje('Error al buscar los registros', 'error');
      } finally {
        this.loading = false;
      }
    },

    validarBusqueda() {
      return this.busqueda.numeroRegistro || 
             this.busqueda.fechaDesde || 
             this.busqueda.fechaHasta;
    },

    limpiarBusqueda() {
      this.busqueda = {
        numeroRegistro: '',
        fechaDesde: '',
        fechaHasta: '',
        estado: ''
      };
      this.registros = [];
      this.mensaje = '';
    },

    formatearFecha(fecha) {
      return new Date(fecha).toLocaleDateString('es-MX');
    },

    formatearMonto(monto) {
      return new Intl.NumberFormat('es-MX', {
        minimumFractionDigits: 2,
        maximumFractionDigits: 2
      }).format(monto);
    },

    mostrarMensaje(texto, tipo) {
      this.mensaje = texto;
      this.tipoMensaje = tipo;
      setTimeout(() => {
        this.mensaje = '';
      }, 5000);
    },

    verDetalle(registro) {
      this.mostrarMensaje(`Visualizando detalle del registro ${registro.numero}`, 'info');
    },

    editarRegistro(registro) {
      this.mostrarMensaje(`Editando registro ${registro.numero}`, 'info');
    },

    exportarExcel() {
      this.mostrarMensaje('Exportando a Excel...', 'info');
    }
  }
}
</script>

<style scoped>
.list-reg-container {
  padding: 20px;
  background-color: #f8f9fa;
  min-height: 100vh;
}

.header-section {
  text-align: center;
  margin-bottom: 30px;
}

.page-title {
  color: #2c3e50;
  font-size: 2.5rem;
  margin-bottom: 10px;
}

.page-subtitle {
  color: #7f8c8d;
  font-size: 1.1rem;
}

.search-section {
  max-width: 800px;
  margin: 0 auto 30px;
}

.search-form {
  background: white;
  padding: 25px;
  border-radius: 10px;
  box-shadow: 0 2px 10px rgba(0,0,0,0.1);
}

.section-title {
  color: #8e44ad;
  font-size: 1.5rem;
  margin-bottom: 20px;
  border-bottom: 2px solid #8e44ad;
  padding-bottom: 10px;
}

.form-row {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 20px;
  margin-bottom: 20px;
}

.form-group {
  display: flex;
  flex-direction: column;
}

.form-group label {
  margin-bottom: 5px;
  font-weight: bold;
  color: #2c3e50;
}

.form-input, .form-select {
  padding: 10px;
  border: 1px solid #bdc3c7;
  border-radius: 5px;
  font-size: 14px;
}

.form-actions {
  display: flex;
  gap: 10px;
  justify-content: center;
}

.btn {
  padding: 10px 20px;
  border: none;
  border-radius: 5px;
  cursor: pointer;
  font-size: 14px;
  font-weight: bold;
  transition: background-color 0.3s;
}

.btn-primary { background-color: #8e44ad; color: white; }
.btn-secondary { background-color: #95a5a6; color: white; }
.btn-success { background-color: #27ae60; color: white; }

.results-section {
  max-width: 1200px;
  margin: 0 auto;
}

.table-container {
  background: white;
  border-radius: 10px;
  overflow: hidden;
  box-shadow: 0 2px 10px rgba(0,0,0,0.1);
}

.results-table {
  width: 100%;
  border-collapse: collapse;
}

.results-table th,
.results-table td {
  padding: 12px;
  text-align: left;
  border-bottom: 1px solid #ecf0f1;
}

.results-table th {
  background-color: #f8f9fa;
  font-weight: bold;
  color: #2c3e50;
}

.estado {
  padding: 4px 8px;
  border-radius: 12px;
  font-size: 12px;
  font-weight: bold;
}

.estado-activo { background: #27ae60; color: white; }
.estado-inactivo { background: #e74c3c; color: white; }
.estado-pendiente { background: #f39c12; color: white; }

.btn-action {
  padding: 5px 10px;
  border: none;
  border-radius: 3px;
  cursor: pointer;
  font-size: 12px;
  margin-right: 5px;
}

.btn-info { background: #3498db; color: white; }
.btn-warning { background: #f39c12; color: white; }

.mensaje {
  position: fixed;
  top: 20px;
  right: 20px;
  padding: 15px 20px;
  border-radius: 5px;
  color: white;
  font-weight: bold;
  z-index: 1000;
}

.mensaje.success { background-color: #27ae60; }
.mensaje.error { background-color: #e74c3c; }
.mensaje.info { background-color: #3498db; }

@media (max-width: 768px) {
  .form-row {
    grid-template-columns: 1fr;
  }
}
</style>