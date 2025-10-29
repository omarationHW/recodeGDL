<template>
  <div class="adeudos-contratos-page">
    <h1>Listados de Adeudos de Contratos</h1>
    <div class="form-section">
      <div class="left-panel">
        <fieldset>
          <legend>Listados</legend>
          <div>
            <label><input type="radio" v-model="tipoListado" value="todos" @change="onTipoListadoChange"> Todos los Convenios Vigentes</label>
          </div>
          <div>
            <label><input type="radio" v-model="tipoListado" value="adeudos" @change="onTipoListadoChange"> Adeudos</label>
          </div>
          <div>
            <label><input type="radio" v-model="tipoListado" value="saldos_favor" @change="onTipoListadoChange"> Saldos a Favor</label>
          </div>
          <div>
            <label><input type="radio" v-model="tipoListado" value="pagos_descuento" @change="onTipoListadoChange"> Pagos con Descuento</label>
          </div>
          <div>
            <label><input type="radio" v-model="tipoListado" value="liquidados" @change="onTipoListadoChange"> Liquidados</label>
          </div>
          <div v-if="tipoListado==='liquidados'">
            <fieldset>
              <legend>Clasificación</legend>
              <label><input type="radio" v-model="clasificacionLiquidados" value="col_calle" @change="onClasificacionChange"> Colonia y Calle</label>
              <label><input type="radio" v-model="clasificacionLiquidados" value="col" @change="onClasificacionChange"> Colonia</label>
            </fieldset>
          </div>
        </fieldset>
      </div>
      <div class="right-panel">
        <div v-if="showColonia">
          <label>Num. Colonia
            <input v-model="colonia" type="number" min="1" @keypress.enter="focusNext('calle')">
          </label>
        </div>
        <div v-if="showCalle">
          <label>Num. Calle
            <input v-model="calle" type="number" min="1" @keypress.enter="focusNext('ejecutar')">
          </label>
        </div>
        <div v-if="showImporte">
          <label>Menor e Igual a
            <input v-model="importe" type="number" min="0" step="0.01">
          </label>
        </div>
        <div class="actions">
          <button @click="ejecutarListado">Ejecutar</button>
        </div>
      </div>
    </div>
    <div class="results-section" v-if="resultados && resultados.length">
      <h2>Resultados</h2>
      <table class="results-table">
        <thead>
          <tr>
            <th v-for="col in columnas" :key="col">{{ col }}</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="(row, idx) in resultados" :key="idx">
            <td v-for="col in columnas" :key="col">{{ row[col] }}</td>
          </tr>
        </tbody>
      </table>
    </div>
    <div v-if="error" class="error">{{ error }}</div>
  </div>
</template>

<script>
export default {
  name: 'AdeudosContratosPage',
  data() {
    return {
      tipoListado: '',
      clasificacionLiquidados: '',
      colonia: '',
      calle: '',
      importe: '',
      resultados: [],
      columnas: [],
      error: '',
    };
  },
  computed: {
    showColonia() {
      if (['todos', 'adeudos', 'saldos_favor', 'liquidados'].includes(this.tipoListado)) return true;
      if (this.tipoListado === 'pagos_descuento') return true;
      return false;
    },
    showCalle() {
      if (['todos', 'adeudos', 'saldos_favor'].includes(this.tipoListado)) return true;
      if (this.tipoListado === 'liquidados' && this.clasificacionLiquidados === 'col_calle') return true;
      return false;
    },
    showImporte() {
      return this.tipoListado === 'liquidados' && this.clasificacionLiquidados === 'col';
    }
  },
  methods: {
    onTipoListadoChange() {
      this.colonia = '';
      this.calle = '';
      this.importe = '';
      this.clasificacionLiquidados = '';
      this.resultados = [];
      this.error = '';
    },
    onClasificacionChange() {
      this.colonia = '';
      this.calle = '';
      this.importe = '';
      this.resultados = [];
      this.error = '';
    },
    focusNext(field) {
      if (field === 'calle') {
        this.$nextTick(() => {
          this.$el.querySelector('input[type=number][v-model="calle"]').focus();
        });
      } else if (field === 'ejecutar') {
        this.$nextTick(() => {
          this.$el.querySelector('button').focus();
        });
      }
    },
    async ejecutarListado() {
      this.error = '';
      this.resultados = [];
      let operation = '';
      let params = {};
      if (this.tipoListado === 'todos') {
        operation = 'listado_todos';
        params = { colonia: this.colonia, calle: this.calle };
      } else if (this.tipoListado === 'adeudos') {
        operation = 'listado_adeudos';
        params = { colonia: this.colonia, calle: this.calle };
      } else if (this.tipoListado === 'saldos_favor') {
        operation = 'listado_saldos_favor';
        params = { colonia: this.colonia, calle: this.calle };
      } else if (this.tipoListado === 'pagos_descuento') {
        operation = 'listado_pagos_descuento';
        params = { colonia: this.colonia };
      } else if (this.tipoListado === 'liquidados') {
        if (this.clasificacionLiquidados === 'col_calle') {
          operation = 'listado_liquidados_col_calle';
          params = { colonia: this.colonia, calle: this.calle };
        } else if (this.clasificacionLiquidados === 'col') {
          operation = 'listado_liquidados_col';
          params = { colonia: this.colonia, importe: this.importe };
        } else {
          this.error = 'Seleccione una clasificación de liquidados.';
          return;
        }
      } else {
        this.error = 'Seleccione un tipo de listado.';
        return;
      }
      try {
        const res = await this.$axios.post('/api/execute', {
          action: `convenios.${operation}`,
          payload: params
        });
        if (res.data.status === 'success') {
          this.resultados = res.data.data || [];
          if (this.resultados.length > 0) {
            this.columnas = Object.keys(this.resultados[0]);
          } else {
            this.columnas = [];
          }
        } else {
          this.error = res.data.message || 'Sin resultados';
        }
      } catch (error) {
        this.error = 'Error de conexión con el servidor';
      }
    }
  }
}
</script>

<style scoped>
.adeudos-contratos-page {
  max-width: 900px;
  margin: 0 auto;
  padding: 2rem;
}
.form-section {
  display: flex;
  gap: 2rem;
}
.left-panel {
  flex: 1;
}
.right-panel {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 1rem;
}
.actions {
  margin-top: 1rem;
}
.results-section {
  margin-top: 2rem;
}
.results-table {
  width: 100%;
  border-collapse: collapse;
}
.results-table th, .results-table td {
  border: 1px solid #ccc;
  padding: 0.5rem;
}
.error {
  color: red;
  margin-top: 1rem;
}
</style>
