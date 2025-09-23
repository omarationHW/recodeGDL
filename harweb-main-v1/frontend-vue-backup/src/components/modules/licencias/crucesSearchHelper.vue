<template>
  <div class="cruces-search-helper">
    <div class="search-section">
      <h3>Búsqueda Avanzada de Calles</h3>

      <div class="search-row">
        <div class="search-field">
          <label>Buscar Calle 1:</label>
          <input
            v-model="searchCalle1"
            @input="buscarCalle1"
            placeholder="Escriba el nombre de la calle..."
            maxlength="40"
          />
          <div v-if="resultadosCalle1.length > 0" class="search-results">
            <div
              v-for="calle in resultadosCalle1"
              :key="calle.cvecalle"
              @click="seleccionarCalle1(calle)"
              class="search-result-item"
            >
              {{ calle.calle }} (ID: {{ calle.cvecalle }})
            </div>
          </div>
        </div>

        <div class="search-field">
          <label>Buscar Calle 2:</label>
          <input
            v-model="searchCalle2"
            @input="buscarCalle2"
            placeholder="Escriba el nombre de la calle..."
            maxlength="40"
          />
          <div v-if="resultadosCalle2.length > 0" class="search-results">
            <div
              v-for="calle in resultadosCalle2"
              :key="calle.cvecalle"
              @click="seleccionarCalle2(calle)"
              class="search-result-item"
            >
              {{ calle.calle }} (ID: {{ calle.cvecalle }})
            </div>
          </div>
        </div>
      </div>

      <div class="selected-streets" v-if="calleSeleccionada1 || calleSeleccionada2">
        <h4>Calles Seleccionadas:</h4>
        <div v-if="calleSeleccionada1" class="selected-street">
          <strong>Calle 1:</strong> {{ calleSeleccionada1.calle }}
          <button @click="limpiarCalle1" class="clear-btn">&times;</button>
        </div>
        <div v-if="calleSeleccionada2" class="selected-street">
          <strong>Calle 2:</strong> {{ calleSeleccionada2.calle }}
          <button @click="limpiarCalle2" class="clear-btn">&times;</button>
        </div>
        <button
          @click="crearCruceConCalles"
          :disabled="!calleSeleccionada1 || !calleSeleccionada2"
          class="btn-create-cruce"
        >
          Crear Cruce con Estas Calles
        </button>
      </div>
    </div>

    <div v-if="error" class="error">{{ error }}</div>
  </div>
</template>

<script>
export default {
  name: 'CrucesSearchHelper',
  props: {
    apiConfig: {
      type: Object,
      required: true
    }
  },
  emits: ['calles-selected'],
  data() {
    return {
      searchCalle1: '',
      searchCalle2: '',
      resultadosCalle1: [],
      resultadosCalle2: [],
      calleSeleccionada1: null,
      calleSeleccionada2: null,
      error: '',
      searchTimeout1: null,
      searchTimeout2: null
    };
  },
  methods: {
    // Método helper para llamadas a la API
    async callAPI(operacion, parametros = [], base = null) {
      const eRequest = {
        Operacion: operacion,
        Base: base || this.apiConfig.database,
        Parametros: parametros,
        Tenant: this.apiConfig.tenant
      }

      const response = await fetch(this.apiConfig.baseUrl, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ eRequest })
      })

      const data = await response.json()

      if (!data.eResponse || !data.eResponse.success) {
        throw new Error(data.eResponse?.message || 'Error en la API')
      }

      return data.eResponse.data
    },

    async buscarCalle1() {
      // Limpiar timeout anterior
      if (this.searchTimeout1) {
        clearTimeout(this.searchTimeout1);
      }

      // Si el input está vacío, limpiar resultados
      if (!this.searchCalle1.trim()) {
        this.resultadosCalle1 = [];
        return;
      }

      // Debounce de 300ms
      this.searchTimeout1 = setTimeout(async () => {
        try {
          this.error = '';
          const parametros = [
            { nombre: 'search_text', valor: this.searchCalle1.trim(), tipo: 'varchar' }
          ];

          const data = await this.callAPI('sp_cruces_search_calle1', parametros);

          if (data && data.result && Array.isArray(data.result)) {
            this.resultadosCalle1 = data.result.slice(0, 10); // Limitar a 10 resultados
          } else {
            this.resultadosCalle1 = [];
          }
        } catch (error) {
          this.error = error.message;
          this.resultadosCalle1 = [];
        }
      }, 300);
    },

    async buscarCalle2() {
      // Limpiar timeout anterior
      if (this.searchTimeout2) {
        clearTimeout(this.searchTimeout2);
      }

      // Si el input está vacío, limpiar resultados
      if (!this.searchCalle2.trim()) {
        this.resultadosCalle2 = [];
        return;
      }

      // Debounce de 300ms
      this.searchTimeout2 = setTimeout(async () => {
        try {
          this.error = '';
          const parametros = [
            { nombre: 'search_text', valor: this.searchCalle2.trim(), tipo: 'varchar' }
          ];

          const data = await this.callAPI('sp_cruces_search_calle1', parametros);

          if (data && data.result && Array.isArray(data.result)) {
            this.resultadosCalle2 = data.result.slice(0, 10); // Limitar a 10 resultados
          } else {
            this.resultadosCalle2 = [];
          }
        } catch (error) {
          this.error = error.message;
          this.resultadosCalle2 = [];
        }
      }, 300);
    },

    seleccionarCalle1(calle) {
      this.calleSeleccionada1 = calle;
      this.searchCalle1 = calle.calle;
      this.resultadosCalle1 = [];
    },

    seleccionarCalle2(calle) {
      this.calleSeleccionada2 = calle;
      this.searchCalle2 = calle.calle;
      this.resultadosCalle2 = [];
    },

    limpiarCalle1() {
      this.calleSeleccionada1 = null;
      this.searchCalle1 = '';
      this.resultadosCalle1 = [];
    },

    limpiarCalle2() {
      this.calleSeleccionada2 = null;
      this.searchCalle2 = '';
      this.resultadosCalle2 = [];
    },

    crearCruceConCalles() {
      if (!this.calleSeleccionada1 || !this.calleSeleccionada2) return;

      const datosCalles = {
        calle1: this.calleSeleccionada1,
        calle2: this.calleSeleccionada2,
        nombreCompleto1: this.calleSeleccionada1.calle,
        nombreCompleto2: this.calleSeleccionada2.calle
      };

      this.$emit('calles-selected', datosCalles);

      // Limpiar selecciones
      this.limpiarCalle1();
      this.limpiarCalle2();
    }
  },

  beforeUnmount() {
    // Limpiar timeouts
    if (this.searchTimeout1) clearTimeout(this.searchTimeout1);
    if (this.searchTimeout2) clearTimeout(this.searchTimeout2);
  }
};
</script>

<style scoped>
.cruces-search-helper {
  background: white;
  border-radius: 8px;
  padding: 20px;
  margin-bottom: 20px;
  box-shadow: 0 2px 4px rgba(0,0,0,0.1);
}

.search-section h3 {
  color: #2c3e50;
  margin-bottom: 15px;
  font-size: 16px;
  font-weight: 600;
}

.search-row {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 20px;
  margin-bottom: 20px;
}

.search-field {
  position: relative;
}

.search-field label {
  display: block;
  font-weight: 500;
  color: #495057;
  margin-bottom: 5px;
  font-size: 14px;
}

.search-field input {
  width: 100%;
  padding: 10px 12px;
  border: 1px solid #ced4da;
  border-radius: 4px;
  font-size: 14px;
  transition: border-color 0.2s;
}

.search-field input:focus {
  outline: none;
  border-color: #007bff;
  box-shadow: 0 0 0 2px rgba(0, 123, 255, 0.25);
}

.search-results {
  position: absolute;
  top: 100%;
  left: 0;
  right: 0;
  background: white;
  border: 1px solid #ced4da;
  border-top: none;
  border-radius: 0 0 4px 4px;
  max-height: 200px;
  overflow-y: auto;
  z-index: 1000;
  box-shadow: 0 2px 4px rgba(0,0,0,0.1);
}

.search-result-item {
  padding: 10px 12px;
  cursor: pointer;
  border-bottom: 1px solid #f8f9fa;
  font-size: 14px;
  transition: background-color 0.2s;
}

.search-result-item:hover {
  background: #f8f9fa;
}

.search-result-item:last-child {
  border-bottom: none;
}

.selected-streets {
  border-top: 1px solid #e9ecef;
  padding-top: 15px;
}

.selected-streets h4 {
  color: #2c3e50;
  margin-bottom: 10px;
  font-size: 14px;
  font-weight: 600;
}

.selected-street {
  display: flex;
  align-items: center;
  justify-content: space-between;
  background: #e3f2fd;
  padding: 8px 12px;
  border-radius: 4px;
  margin-bottom: 8px;
  font-size: 14px;
}

.clear-btn {
  background: none;
  border: none;
  color: #dc3545;
  font-size: 18px;
  font-weight: bold;
  cursor: pointer;
  padding: 0;
  width: 20px;
  height: 20px;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: 50%;
  transition: all 0.2s;
}

.clear-btn:hover {
  background: #dc3545;
  color: white;
}

.btn-create-cruce {
  background: #28a745;
  color: white;
  border: none;
  padding: 10px 20px;
  border-radius: 4px;
  cursor: pointer;
  font-size: 14px;
  font-weight: 500;
  transition: all 0.2s;
  margin-top: 10px;
}

.btn-create-cruce:hover:not(:disabled) {
  background: #218838;
}

.btn-create-cruce:disabled {
  background: #6c757d;
  cursor: not-allowed;
}

.error {
  background: #f8d7da;
  color: #721c24;
  padding: 12px 16px;
  border-radius: 4px;
  border: 1px solid #f5c6cb;
  margin-top: 15px;
  font-size: 14px;
}

/* Responsive */
@media (max-width: 768px) {
  .search-row {
    grid-template-columns: 1fr;
    gap: 15px;
  }

  .selected-street {
    flex-direction: column;
    align-items: flex-start;
    gap: 5px;
  }
}
</style>