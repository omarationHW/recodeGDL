<template>
  <div class="entrega-ejecutor-page">
    <h1>Entrega de Requerimientos por Ejecutor</h1>
    <div class="breadcrumb">
      <router-link to="/">Inicio</router-link> / Entrega de Requerimientos
    </div>
    <section class="busqueda-ejecutor">
      <h2>Búsqueda de Ejecutor</h2>
      <form @submit.prevent="buscarEjecutor">
        <label>
          Buscar por:
          <select v-model="tipoBusqueda">
            <option value="numero">Número</option>
            <option value="nombre">Nombre</option>
          </select>
        </label>
        <input v-model="criterio" placeholder="Ingrese criterio de búsqueda" required />
        <button type="submit">Buscar</button>
      </form>
      <div v-if="ejecutores.length">
        <h3>Resultados:</h3>
        <table class="table table-bordered">
          <thead>
            <tr>
              <th>Número</th>
              <th>Nombre Completo</th>
              <th>Recaudadora</th>
              <th>Acción</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="e in ejecutores" :key="e.cveejecutor">
              <td>{{ e.cveejecutor }}</td>
              <td>{{ e.ncompleto }}</td>
              <td>{{ e.recaud }}</td>
              <td><button @click="seleccionarEjecutor(e)">Seleccionar</button></td>
            </tr>
          </tbody>
        </table>
      </div>
    </section>
    <section v-if="ejecutorSeleccionado">
      <h2>Entrega de Requerimientos a: {{ ejecutorSeleccionado.ncompleto }}</h2>
      <form @submit.prevent="filtrarRequerimientos">
        <label>Recaudadora:
          <input v-model="recaudadora" type="number" required />
        </label>
        <label>Fecha de Entrega:
          <input v-model="fechaEntrega" type="date" required />
        </label>
        <button type="submit">Filtrar Requerimientos</button>
      </form>
      <div v-if="requerimientos.length">
        <h3>Requerimientos asignados</h3>
        <table class="table table-striped">
          <thead>
            <tr>
              <th>Folio</th>
              <th>Cuenta</th>
              <th>Importe</th>
              <th>Recargos</th>
              <th>Gastos</th>
              <th>Multas</th>
              <th>Total</th>
              <th>Acción</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="r in requerimientos" :key="r.folioreq">
              <td>{{ r.folioreq }}</td>
              <td>{{ r.cvecuenta }}</td>
              <td>{{ r.impuesto | currency }}</td>
              <td>{{ r.recargos | currency }}</td>
              <td>{{ r.gastos | currency }}</td>
              <td>{{ r.multas | currency }}</td>
              <td>{{ r.total | currency }}</td>
              <td>
                <button @click="quitarRequerimiento(r)">Quitar</button>
              </td>
            </tr>
          </tbody>
        </table>
        <button @click="imprimirEntrega">Imprimir Entrega</button>
      </div>
      <div v-else>
        <p>No hay requerimientos asignados para este ejecutor y fecha.</p>
      </div>
    </section>
    <div v-if="mensaje" class="alert alert-info">{{ mensaje }}</div>
  </div>
</template>

<script>
export default {
  name: 'EntregaEjecutorPage',
  data() {
    return {
      tipoBusqueda: 'numero',
      criterio: '',
      ejecutores: [],
      ejecutorSeleccionado: null,
      recaudadora: '',
      fechaEntrega: '',
      requerimientos: [],
      mensaje: ''
    };
  },
  methods: {
    async buscarEjecutor() {
      this.mensaje = '';
      this.ejecutores = [];
      this.ejecutorSeleccionado = null;
      this.requerimientos = [];
      try {
        const res = await this.$axios.post('/api/execute', {
          action: 'buscar_ejecutor',
          params: {
            criterio: this.criterio,
            tipo: this.tipoBusqueda
          }
        });
        if (res.data.success) {
          this.ejecutores = res.data.data;
          if (this.ejecutores.length === 1) {
            this.seleccionarEjecutor(this.ejecutores[0]);
          }
        } else {
          this.mensaje = res.data.message || 'No se encontraron ejecutores.';
        }
      } catch (e) {
        this.mensaje = 'Error en la búsqueda.';
      }
    },
    seleccionarEjecutor(ejecutor) {
      this.ejecutorSeleccionado = ejecutor;
      this.recaudadora = ejecutor.recaud;
      this.fechaEntrega = new Date().toISOString().substr(0, 10);
      this.requerimientos = [];
      this.mensaje = '';
    },
    async filtrarRequerimientos() {
      this.mensaje = '';
      this.requerimientos = [];
      try {
        const res = await this.$axios.post('/api/execute', {
          action: 'listar_requerimientos',
          params: {
            cveejecutor: this.ejecutorSeleccionado.cveejecutor,
            recaud: this.recaudadora,
            fecha: this.fechaEntrega
          }
        });
        if (res.data.success) {
          this.requerimientos = res.data.data;
        } else {
          this.mensaje = res.data.message || 'No hay requerimientos.';
        }
      } catch (e) {
        this.mensaje = 'Error al filtrar requerimientos.';
      }
    },
    async quitarRequerimiento(req) {
      if (!confirm('¿Está seguro de quitar este requerimiento?')) return;
      try {
        const res = await this.$axios.post('/api/execute', {
          action: 'quitar_requerimiento',
          params: {
            folio: req.folioreq,
            recaud: this.recaudadora,
            cveejecutor: this.ejecutorSeleccionado.cveejecutor
          }
        });
        if (res.data.success) {
          this.filtrarRequerimientos();
        } else {
          this.mensaje = res.data.message || 'No se pudo quitar el requerimiento.';
        }
      } catch (e) {
        this.mensaje = 'Error al quitar requerimiento.';
      }
    },
    async imprimirEntrega() {
      try {
        const res = await this.$axios.post('/api/execute', {
          action: 'imprimir_entrega',
          params: {
            cveejecutor: this.ejecutorSeleccionado.cveejecutor,
            recaud: this.recaudadora,
            fecha: this.fechaEntrega
          }
        });
        if (res.data.success) {
          // Aquí puedes abrir un modal de impresión o generar PDF
          alert('Datos listos para impresión. Implementar PDF/impresión.');
        } else {
          this.mensaje = res.data.message || 'No se pudo generar la impresión.';
        }
      } catch (e) {
        this.mensaje = 'Error al imprimir.';
      }
    }
  },
  filters: {
    currency(val) {
      if (typeof val !== 'number') return val;
      return '$' + val.toLocaleString('es-MX', { minimumFractionDigits: 2 });
    }
  }
};
</script>

<style scoped>
.entrega-ejecutor-page {
  max-width: 1100px;
  margin: 0 auto;
  padding: 2rem;
}
.breadcrumb {
  margin-bottom: 1rem;
}
.table {
  width: 100%;
  border-collapse: collapse;
}
.table th, .table td {
  border: 1px solid #ccc;
  padding: 0.5rem;
}
.alert {
  margin-top: 1rem;
}
</style>
