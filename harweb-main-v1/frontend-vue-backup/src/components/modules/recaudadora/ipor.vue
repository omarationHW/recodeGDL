<template>
  <div class="ipor-formulario">
    <h1>Impresión de Orden de Requerimiento</h1>
    <div class="form-section">
      <div class="filters">
        <label>Recaudadora:
          <input v-model="filters.recaud" type="number" min="1" />
        </label>
        <label>Fecha Emisión:
          <input v-model="filters.fecha_emision" type="date" />
        </label>
        <label>
          <input type="checkbox" v-model="filters.ult_impreso_lt_folio_final" />
          Faltantes por imprimir
        </label>
        <button @click="buscarControles">Buscar</button>
      </div>
      <table class="controls-table">
        <thead>
          <tr>
            <th>Emisión</th>
            <th>Criterio</th>
            <th>Adeudo hasta</th>
            <th>Rec</th>
            <th>UR</th>
            <th>Cta Inicio</th>
            <th>Cta Fin</th>
            <th>Zona</th>
            <th>Subzona</th>
            <th>Folio Inicio</th>
            <th>Folio Fin</th>
            <th>Monto Min</th>
            <th>Monto Max</th>
            <th>Impuesto</th>
            <th>Recargos</th>
            <th>Gasto</th>
            <th>Multa</th>
            <th>Emitió</th>
            <th>Hora</th>
            <th>Ult. Impresión</th>
            <th>Imprimió</th>
            <th>Hora</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="ctrl in controles" :key="ctrl.id">
            <td>{{ ctrl.fecha_emision }}</td>
            <td>{{ ctrl.criterio }}</td>
            <td>{{ ctrl.hasta }}</td>
            <td>{{ ctrl.recaud }}</td>
            <td>{{ ctrl.urbrus }}</td>
            <td>{{ ctrl.cuenta_inicio }}</td>
            <td>{{ ctrl.cuenta_final }}</td>
            <td>{{ ctrl.zona }}</td>
            <td>{{ ctrl.subzona }}</td>
            <td>{{ ctrl.folio_inicio }}</td>
            <td>{{ ctrl.folio_final }}</td>
            <td>{{ ctrl.monto_min }}</td>
            <td>{{ ctrl.monto_max }}</td>
            <td>{{ ctrl.tot_impuesto }}</td>
            <td>{{ ctrl.tot_recargos }}</td>
            <td>{{ ctrl.tot_gastos }}</td>
            <td>{{ ctrl.tot_multa }}</td>
            <td>{{ ctrl.usr_emision }}</td>
            <td>{{ ctrl.hrs_emision }}</td>
            <td>{{ ctrl.ult_impreso }}</td>
            <td>{{ ctrl.usr_impresion }}</td>
            <td>{{ ctrl.hrs_impresion }}</td>
          </tr>
        </tbody>
      </table>
    </div>
    <div class="actions">
      <button @click="abrirAsignacion">Asignar Requerimientos</button>
      <button @click="abrirImpresion">Imprimir Requerimientos</button>
    </div>
    <div v-if="showAsignacion" class="asignacion-section">
      <h2>Asignar Requerimientos</h2>
      <form @submit.prevent="asignarRequerimientos">
        <label>Tipo:
          <select v-model="asignacion.tipo">
            <option value="predial">Predial</option>
            <option value="multas">Multas</option>
            <option value="licencias">Licencias</option>
            <option value="anuncios">Anuncios</option>
            <option value="diferencias">Diferencias</option>
          </select>
        </label>
        <label>Ejecutor:
          <input v-model="asignacion.ejecutor_id" type="number" min="1" />
        </label>
        <label>Fecha:
          <input v-model="asignacion.fecha" type="date" />
        </label>
        <label>Recaudadora:
          <input v-model="asignacion.recaud" type="number" min="1" />
        </label>
        <label>Folio Inicial:
          <input v-model="asignacion.folioini" type="number" min="1" />
        </label>
        <label>Folio Final:
          <input v-model="asignacion.foliofin" type="number" min="1" />
        </label>
        <button type="submit">Asignar</button>
        <button type="button" @click="showAsignacion=false">Cancelar</button>
      </form>
      <div v-if="asignacionResult">
        <pre>{{ asignacionResult }}</pre>
      </div>
    </div>
    <div v-if="showImpresion" class="impresion-section">
      <h2>Imprimir Requerimientos</h2>
      <form @submit.prevent="imprimirRequerimientos">
        <label>Fecha:
          <input v-model="impresion.fecha" type="date" />
        </label>
        <label>Recaudadora:
          <input v-model="impresion.recaud" type="number" min="1" />
        </label>
        <label>Tipo Impresión:
          <select v-model="impresion.tipo_impresion">
            <option value="notificacion">Notificación</option>
            <option value="requerimiento">Requerimiento</option>
          </select>
        </label>
        <label>Ejecutor:
          <input v-model="impresion.ejecutor_id" type="number" min="1" />
        </label>
        <button type="submit">Imprimir</button>
        <button type="button" @click="showImpresion=false">Cancelar</button>
      </form>
      <div v-if="impresionResult">
        <pre>{{ impresionResult }}</pre>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'IporFormulario',
  data() {
    return {
      filters: {
        recaud: '',
        fecha_emision: '',
        ult_impreso_lt_folio_final: false
      },
      controles: [],
      showAsignacion: false,
      showImpresion: false,
      asignacion: {
        tipo: 'predial',
        ejecutor_id: '',
        fecha: '',
        recaud: '',
        folioini: '',
        foliofin: ''
      },
      asignacionResult: null,
      impresion: {
        fecha: '',
        recaud: '',
        tipo_impresion: 'notificacion',
        ejecutor_id: ''
      },
      impresionResult: null
    };
  },
  methods: {
    async buscarControles() {
      const res = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          eRequest: {
            action: 'filter_controls',
            params: this.filters
          }
        })
      });
      const data = await res.json();
      this.controles = data.eResponse.result || [];
    },
    abrirAsignacion() {
      this.showAsignacion = true;
      this.showImpresion = false;
    },
    abrirImpresion() {
      this.showImpresion = true;
      this.showAsignacion = false;
    },
    async asignarRequerimientos() {
      const res = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          eRequest: {
            action: 'assign_requerimientos',
            params: this.asignacion
          }
        })
      });
      const data = await res.json();
      this.asignacionResult = data.eResponse.result || data.eResponse.error;
    },
    async imprimirRequerimientos() {
      const res = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          eRequest: {
            action: 'print_requerimientos',
            params: this.impresion
          }
        })
      });
      const data = await res.json();
      this.impresionResult = data.eResponse.result || data.eResponse.error;
    }
  },
  mounted() {
    this.buscarControles();
  }
};
</script>

<style scoped>
.ipor-formulario {
  max-width: 1200px;
  margin: 0 auto;
  padding: 2rem;
}
.form-section {
  margin-bottom: 2rem;
}
.filters {
  display: flex;
  gap: 1rem;
  align-items: center;
  margin-bottom: 1rem;
}
.controls-table {
  width: 100%;
  border-collapse: collapse;
}
.controls-table th, .controls-table td {
  border: 1px solid #ccc;
  padding: 0.5rem;
  text-align: left;
}
.actions {
  margin-bottom: 2rem;
}
.asignacion-section, .impresion-section {
  background: #f9f9f9;
  padding: 1rem;
  border: 1px solid #ddd;
  margin-bottom: 2rem;
}
</style>
