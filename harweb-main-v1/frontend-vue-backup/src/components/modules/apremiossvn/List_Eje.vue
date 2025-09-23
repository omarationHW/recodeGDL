<template>
  <div class="list-eje-container">
    <div class="header-section">
      <h1 class="page-title">Lista de Ejecutores</h1>
      <p class="page-subtitle">Gestión y consulta de ejecutores del sistema</p>
    </div>

    <div class="content-section">
      <div class="search-section">
        <h2 class="section-title">Filtros</h2>
        
        <div class="form-row">
          <div class="form-group">
            <label>Nombre del Ejecutor:</label>
            <input 
              v-model="filtros.nombre"
              type="text" 
              class="form-input"
              placeholder="Ingrese nombre del ejecutor"
            />
          </div>
          
          <div class="form-group">
            <label>Clave:</label>
            <input 
              v-model="filtros.clave"
              type="text" 
              class="form-input"
              placeholder="Ingrese clave del ejecutor"
            />
          </div>
        </div>

        <div class="form-row">
          <div class="form-group">
            <label>Estado:</label>
            <select v-model="filtros.estado" class="form-select">
              <option value="">Todos los estados</option>
              <option value="activo">Activo</option>
              <option value="inactivo">Inactivo</option>
              <option value="suspendido">Suspendido</option>
            </select>
          </div>
          
          <div class="form-group">
            <label>Zona:</label>
            <select v-model="filtros.zona" class="form-select">
              <option value="">Todas las zonas</option>
              <option value="centro">Centro</option>
              <option value="norte">Norte</option>
              <option value="sur">Sur</option>
              <option value="este">Este</option>
              <option value="oeste">Oeste</option>
            </select>
          </div>
        </div>

        <div class="form-actions">
          <button @click="buscarEjecutores" :disabled="loading" class="btn btn-primary">
            {{ loading ? 'Buscando...' : 'Buscar' }}
          </button>
          <button @click="limpiarFiltros" class="btn btn-secondary">Limpiar</button>
          <button @click="exportarExcel" class="btn btn-success">Exportar Excel</button>
        </div>
      </div>

      <div v-if="ejecutores.length > 0" class="results-section">
        <h2 class="section-title">Ejecutores ({{ ejecutores.length }} registros)</h2>
        
        <div class="table-container">
          <table class="results-table">
            <thead>
              <tr>
                <th>Clave</th>
                <th>Nombre Completo</th>
                <th>Zona Asignada</th>
                <th>Estado</th>
                <th>Fecha Alta</th>
                <th>Acciones</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="ejecutor in ejecutoresFiltrados" :key="ejecutor.id">
                <td>{{ ejecutor.clave }}</td>
                <td>{{ ejecutor.nombreCompleto }}</td>
                <td>{{ ejecutor.zona }}</td>
                <td>
                  <span :class="['estado', `estado-${ejecutor.estado}`]">
                    {{ ejecutor.estado }}
                  </span>
                </td>
                <td>{{ formatearFecha(ejecutor.fechaAlta) }}</td>
                <td>
                  <button @click="verDetalle(ejecutor)" class="btn-action btn-info">Ver</button>
                  <button @click="editarEjecutor(ejecutor)" class="btn-action btn-warning">Editar</button>
                  <button @click="cambiarEstado(ejecutor)" class="btn-action btn-danger">{{ ejecutor.estado === 'activo' ? 'Suspender' : 'Activar' }}</button>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>

    <div v-if="mensaje" class="mensaje" :class="tipoMensaje">
      {{ mensaje }}
    </div>
  </div>
</template>

<script>
export default {
  name: 'ListEje',
  data() {
    return {
      loading: false,
      mensaje: '',
      tipoMensaje: '',
      filtros: {
        nombre: '',
        clave: '',
        estado: '',
        zona: ''
      },
      ejecutores: [
        {
          id: 1,
          clave: 'EJ001',
          nombreCompleto: 'Juan Carlos Pérez Martínez',
          zona: 'Centro',
          estado: 'activo',
          fechaAlta: '2023-01-15'
        },
        {
          id: 2,
          clave: 'EJ002',
          nombreCompleto: 'María Elena González Rodríguez',
          zona: 'Norte',
          estado: 'activo',
          fechaAlta: '2023-02-20'
        },
        {
          id: 3,
          clave: 'EJ003',
          nombreCompleto: 'Roberto Silva Hernández',
          zona: 'Sur',
          estado: 'suspendido',
          fechaAlta: '2023-03-10'
        }
      ]
    }
  },
  computed: {
    ejecutoresFiltrados() {
      return this.ejecutores.filter(ejecutor => {
        const matchNombre = !this.filtros.nombre || 
          ejecutor.nombreCompleto.toLowerCase().includes(this.filtros.nombre.toLowerCase());
        const matchClave = !this.filtros.clave || 
          ejecutor.clave.toLowerCase().includes(this.filtros.clave.toLowerCase());
        const matchEstado = !this.filtros.estado || ejecutor.estado === this.filtros.estado;
        const matchZona = !this.filtros.zona || ejecutor.zona.toLowerCase() === this.filtros.zona.toLowerCase();
        
        return matchNombre && matchClave && matchEstado && matchZona;
      });
    }
  },
  methods: {
    async buscarEjecutores() {
      this.loading = true;
      
      try {
        await new Promise(resolve => setTimeout(resolve, 1000));
        this.mostrarMensaje('Búsqueda completada', 'success');
      } catch (error) {
        this.mostrarMensaje('Error al buscar ejecutores', 'error');
      } finally {
        this.loading = false;
      }
    },

    limpiarFiltros() {
      this.filtros = {
        nombre: '',
        clave: '',
        estado: '',
        zona: ''
      };
      this.mensaje = '';
    },

    formatearFecha(fecha) {
      return new Date(fecha).toLocaleDateString('es-MX');
    },

    mostrarMensaje(texto, tipo) {
      this.mensaje = texto;
      this.tipoMensaje = tipo;
      setTimeout(() => {
        this.mensaje = '';
      }, 5000);
    },

    verDetalle(ejecutor) {
      this.mostrarMensaje(`Visualizando detalle del ejecutor ${ejecutor.clave}`, 'info');
    },

    editarEjecutor(ejecutor) {
      this.mostrarMensaje(`Editando ejecutor ${ejecutor.clave}`, 'info');
    },

    cambiarEstado(ejecutor) {
      const nuevoEstado = ejecutor.estado === 'activo' ? 'suspendido' : 'activo';
      ejecutor.estado = nuevoEstado;
      this.mostrarMensaje(`Estado del ejecutor ${ejecutor.clave} cambiado a ${nuevoEstado}`, 'success');
    },

    exportarExcel() {
      this.mostrarMensaje('Exportando a Excel...', 'info');
    }
  }
}
</script>

<style scoped>
.list-eje-container {
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

.content-section {
  max-width: 1200px;
  margin: 0 auto;
}

.search-section {
  background: white;
  padding: 25px;
  border-radius: 10px;
  box-shadow: 0 2px 10px rgba(0,0,0,0.1);
  margin-bottom: 30px;
}

.section-title {
  color: #9b59b6;
  font-size: 1.5rem;
  margin-bottom: 20px;
  border-bottom: 2px solid #9b59b6;
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

.btn-primary { background-color: #9b59b6; color: white; }
.btn-secondary { background-color: #95a5a6; color: white; }
.btn-success { background-color: #27ae60; color: white; }

.results-section {
  background: white;
  padding: 25px;
  border-radius: 10px;
  box-shadow: 0 2px 10px rgba(0,0,0,0.1);
}

.table-container {
  overflow-x: auto;
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
.estado-inactivo { background: #95a5a6; color: white; }
.estado-suspendido { background: #e74c3c; color: white; }

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
.btn-danger { background: #e74c3c; color: white; }

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
  
  .form-actions {
    flex-direction: column;
  }
}
</style>