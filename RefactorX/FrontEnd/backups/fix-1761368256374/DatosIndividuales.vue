<template>
  <div class="module-view">
    <nav class="breadcrumb">
      <router-link to="/">Inicio</router-link> /
      <span>Consulta Individual de Datos Generales</span>
    </nav>
    <h1>Consulta Individual de Datos Generales</h1>
    <div v-if="loading" class="loading">Cargando...</div>
    <div v-else-if="error" class="error">{{ error }}</div>
    <div v-else>
      <section class="datos-mercado">
        <h2>Datos del Mercado</h2>
        <div class="row">
          <label>Control:</label>
          <span>{{ datos.id_local }}</span>
        </div>
        <div class="row">
          <label>Mercado:</label>
          <span>{{ mercado.descripcion }}</span>
        </div>
        <div class="row">
          <label>Nombre:</label>
          <span>{{ datos.nombre }}</span>
        </div>
        <div class="row">
          <label>Arrendatario:</label>
          <span>{{ datos.arrendatario }}</span>
        </div>
        <div class="row">
          <label>Domicilio:</label>
          <span>{{ datos.domicilio }}</span>
        </div>
        <div class="row">
          <label>Sector:</label>
          <span>{{ datos.sector }}</span>
        </div>
        <div class="row">
          <label>Zona:</label>
          <span>{{ datos.zona }}</span>
        </div>
        <div class="row">
          <label>Descripción:</label>
          <span>{{ datos.descripcion_local }}</span>
        </div>
        <div class="row">
          <label>Superficie:</label>
          <span>{{ datos.superficie }}</span>
        </div>
        <div class="row">
          <label>Giro:</label>
          <span>{{ datos.giro }}</span>
        </div>
        <div class="row">
          <label>Fecha Alta:</label>
          <span>{{ datos.fecha_alta }}</span>
        </div>
        <div class="row">
          <label>Fecha Baja:</label>
          <span>{{ datos.fecha_baja }}</span>
        </div>
        <div class="row">
          <label>Actualización:</label>
          <span>{{ datos.fecha_modificacion }}</span>
        </div>
        <div class="row">
          <label>Vigencia:</label>
          <span>{{ datos.vigencia }}</span>
        </div>
        <div class="row">
          <label>Usuario:</label>
          <span>{{ usuario.nombre }}</span>
        </div>
        <div class="row">
          <label>Renta:</label>
          <span>{{ cuota.renta }}</span>
        </div>
        <div v-if="tianguis">
          <div class="row">
            <label>Descuento:</label>
            <span>{{ tianguis.Descuento }}</span>
          </div>
          <div class="row">
            <label>Motivo Descuento:</label>
            <span>{{ tianguis.MotivoDescuento }}</span>
          </div>
        </div>
      </section>
      <section class="adeudos">
        <h2>Adeudos</h2>
        <table class="municipal-table">
          <thead>
            <tr>
              <th>Año</th>
              <th>Mes</th>
              <th>Importe</th>
              <th>Recargos</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="a in adeudos" :key="a.axo + '-' + a.periodo">
              <td>{{ a.axo }}</td>
              <td>{{ a.periodo }}</td>
              <td>{{ a.importe }}</td>
              <td>{{ a.recargos }}</td>
            </tr>
          </tbody>
        </table>
      </section>
      <section class="requerimientos">
        <h2>Requerimientos</h2>
        <table class="municipal-table">
          <thead>
            <tr>
              <th>Folio</th>
              <th>Fecha Emisión</th>
              <th>Importe Multa</th>
              <th>Importe Gastos</th>
              <th>Vigencia</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="r in requerimientos" :key="r.folio">
              <td>{{ r.folio }}</td>
              <td>{{ r.fecha_emision }}</td>
              <td>{{ r.importe_multa }}</td>
              <td>{{ r.importe_gastos }}</td>
              <td>{{ r.vigencia }}</td>
            </tr>
          </tbody>
        </table>
      </section>
      <section class="movimientos">
        <h2>Movimientos</h2>
        <table class="municipal-table">
          <thead>
            <tr>
              <th>Año Memo</th>
              <th>Número Memo</th>
              <th>Nombre</th>
              <th>Tipo Movimiento</th>
              <th>Fecha</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="m in movimientos" :key="m.id_movimiento">
              <td>{{ m.axo_memo }}</td>
              <td>{{ m.numero_memo }}</td>
              <td>{{ m.nombre }}</td>
              <td>{{ m.tipo_movimiento }}</td>
              <td>{{ m.fecha }}</td>
            </tr>
          </tbody>
        </table>
      </section>
    </div>
  </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'DatosIndividualesPage',
  data() {
    return {
      loading: true,
      error: '',
      datos: {},
      mercado: {},
      usuario: {},
      cuota: {},
      adeudos: [],
      requerimientos: [],
      movimientos: [],
      tianguis: null
    };
  },
  async created() {
    try {
      const id_local = this.$route.params.id_local;
      // 1. Datos principales
      let res = await this.api('getDatosIndividuales', { id_local });
      this.datos = res;
      // 2. Mercado
      res = await this.api('getMercado', { oficina: res.oficina, num_mercado: res.num_mercado });
      this.mercado = res[0] || {};
      // 3. Usuario
      res = await this.api('getUsuario', { id_usuario: this.datos.id_usuario });
      this.usuario = res[0] || {};
      // 4. Cuota
      res = await this.api('getCuota', {
        axo: new Date().getFullYear(),
        categoria: this.datos.categoria,
        seccion: this.datos.seccion,
        clave_cuota: this.datos.clave_cuota
      });
      this.cuota = res[0] || {};
      // 5. Adeudos
      this.adeudos = await this.api('getAdeudos', { id_local });
      // 6. Requerimientos
      this.requerimientos = await this.api('getRequerimientos', { id_local });
      // 7. Movimientos
      this.movimientos = await this.api('getMovimientos', { id_local });
      // 8. Tianguis (si aplica)
      if (this.datos.num_mercado === 214) {
        res = await this.api('getTianguis', { folio: this.datos.local });
        this.tianguis = res[0] || null;
      }
      this.loading = false;
    } catch (e) {
      this.error = e.message || 'Error al cargar datos';
      this.loading = false;
    }
  },
  methods: {
    async api(action, params) {
      const resp = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ action, params })
      });
      const json = await resp.json();
      if (!json.success) throw new Error(json.message || 'Error API');
      return json.data;
    }
  }
};
</script>

<style scoped>
.datos-individuales-page {
  max-width: 1100px;
  margin: 0 auto;
  padding: 2rem;
}
.breadcrumb {
  margin-bottom: 1rem;
}
.row {
  display: flex;
  margin-bottom: 0.5rem;
}
.row label {
  width: 150px;
  font-weight: bold;
}
.table {
  width: 100%;
  border-collapse: collapse;
  margin-bottom: 1.5rem;
}
.table th, .table td {
  border: 1px solid #ccc;
  padding: 0.3rem 0.5rem;
}
.loading {
  color: #888;
}
.error {
  color: red;
}
</style>
