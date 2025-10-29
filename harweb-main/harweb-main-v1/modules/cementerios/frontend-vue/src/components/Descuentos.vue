<template>
  <div class="descuentos-page">
    <h1>Gestión de Descuentos</h1>
    <div class="breadcrumb">
      <router-link to="/">Inicio</router-link> / Descuentos
    </div>
    <div class="form-section">
      <label for="folio">Folio:</label>
      <input v-model="folio" id="folio" type="number" @keyup.enter="buscarFolio" />
      <button @click="buscarFolio">Buscar</button>
      <span v-if="fosa">Nombre: {{ fosa.nombre }}</span>
    </div>
    <div v-if="adeudos.length > 0" class="adeudos-section">
      <h2>Adeudos Vigentes</h2>
      <table class="table">
        <thead>
          <tr>
            <th>Año</th>
            <th>Importe</th>
            <th>Recargos</th>
            <th>Descto Importe</th>
            <th>Descto Recargos</th>
            <th>Seleccionar</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="(a, idx) in adeudos" :key="a.id_adeudo">
            <td>{{ a.axo_adeudo }}</td>
            <td>{{ a.importe }}</td>
            <td>{{ a.importe_recargos }}</td>
            <td>{{ a.descto_impote }}</td>
            <td>{{ a.descto_recargos }}</td>
            <td><input type="radio" name="adeudoSel" :value="idx" v-model="adeudoSelIdx" /></td>
          </tr>
        </tbody>
      </table>
      <button @click="mostrarTiposDescuento" :disabled="adeudoSelIdx === null">Aplicar Descuento</button>
    </div>
    <div v-if="tiposDescuento.length > 0 && showTipos" class="tipos-section">
      <h2>Tipos de Descuento</h2>
      <table class="table">
        <thead>
          <tr>
            <th>Año</th>
            <th>Tipo</th>
            <th>Descripción</th>
            <th>Porcentaje</th>
            <th>Seleccionar</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="(t, idx) in tiposDescuento" :key="t.tipo_descto">
            <td>{{ t.axo_descto }}</td>
            <td>{{ t.tipo_descto }}</td>
            <td>{{ t.descrip_descto }}</td>
            <td>{{ t.porcentaje }}</td>
            <td><input type="radio" name="tipoSel" :value="idx" v-model="tipoSelIdx" /></td>
          </tr>
        </tbody>
      </table>
      <label><input type="checkbox" v-model="reactivar" /> Reactivar siguiente año en curso</label>
      <button @click="aplicarDescuento" :disabled="tipoSelIdx === null">Confirmar Descuento</button>
    </div>
    <div v-if="registros.length > 0" class="registros-section">
      <h2>Descuentos Registrados</h2>
      <table class="table">
        <thead>
          <tr>
            <th>Folio Des</th>
            <th>Año</th>
            <th>Porcent</th>
            <th>Descripción</th>
            <th>Vig</th>
            <th>Alta</th>
            <th>Capturó</th>
            <th>Reac Sig</th>
            <th>Mov</th>
            <th>Usuario Mov</th>
            <th>Acción</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="(r, idx) in registros" :key="r.control_des">
            <td>{{ r.control_des }}</td>
            <td>{{ r.axo_descto }}</td>
            <td>{{ r.descuento }}</td>
            <td>{{ r.descrip_descto }}</td>
            <td>{{ r.vigencia }}</td>
            <td>{{ r.fecha_alta }}</td>
            <td>{{ r.nombre }}</td>
            <td>{{ r.reactivar }}</td>
            <td>{{ r.fecha_mov }}</td>
            <td>{{ r.nombre_1 }}</td>
            <td>
              <button @click="borrarDescuento(r)">Borrar</button>
            </td>
          </tr>
        </tbody>
      </table>
      <button @click="reactivarDescuento" v-if="registros.length > 0">Reactivar Descuento</button>
    </div>
    <div v-if="mensaje" class="mensaje">
      {{ mensaje }}
    </div>
  </div>
</template>

<script>
export default {
  name: 'DescuentosPage',
  data() {
    return {
      folio: '',
      fosa: null,
      adeudos: [],
      adeudoSelIdx: null,
      tiposDescuento: [],
      tipoSelIdx: null,
      registros: [],
      mensaje: '',
      showTipos: false,
      reactivar: false,
      usuario: 1 // Simulación usuario logueado
    };
  },
  methods: {
    async buscarFolio() {
      this.mensaje = '';
      this.fosa = null;
      this.adeudos = [];
      this.registros = [];
      this.tiposDescuento = [];
      this.showTipos = false;
      this.adeudoSelIdx = null;
      if (!this.folio) {
        this.mensaje = 'Ingrese un folio válido';
        return;
      }
      // Consultar fosa
      let resp = await this.api('consultar', { control_rcm: this.folio });
      if (!resp.ok || !resp.data) {
        this.mensaje = 'Registro de fosa no encontrado';
        return;
      }
      this.fosa = resp.data;
      // Consultar adeudos
      let ade = await this.api('adeudos', { control_rcm: this.folio });
      this.adeudos = ade.data || [];
      if (this.adeudos.length === 0) {
        this.mensaje = 'Registro de fosa no tiene adeudos vigentes';
      }
      // Consultar descuentos registrados
      let reg = await this.api('registro', { control_rcm: this.folio });
      this.registros = reg.data || [];
    },
    async mostrarTiposDescuento() {
      this.showTipos = false;
      this.tipoSelIdx = null;
      if (this.adeudoSelIdx === null) {
        this.mensaje = 'Seleccione un adeudo';
        return;
      }
      let axo = this.adeudos[this.adeudoSelIdx].axo_adeudo;
      let tipos = await this.api('tipos', { axo });
      this.tiposDescuento = tipos.data || [];
      this.showTipos = true;
    },
    async aplicarDescuento() {
      if (this.adeudoSelIdx === null || this.tipoSelIdx === null) {
        this.mensaje = 'Seleccione adeudo y tipo de descuento';
        return;
      }
      let adeudo = this.adeudos[this.adeudoSelIdx];
      let tipo = this.tiposDescuento[this.tipoSelIdx];
      let params = {
        control_rcm: this.folio,
        axo: adeudo.axo_adeudo,
        porcentaje: tipo.porcentaje,
        usuario: this.usuario,
        reactivar: this.reactivar ? 'S' : 'N',
        tipo_descto: tipo.tipo_descto
      };
      let resp = await this.api('alta', params);
      this.mensaje = resp.message;
      if (resp.ok) {
        this.showTipos = false;
        this.buscarFolio();
      }
    },
    async borrarDescuento(reg) {
      if (!confirm('¿Está seguro de borrar el descuento?')) return;
      let params = {
        control_rcm: reg.control_rcm,
        axo: reg.axo_descto,
        porcentaje: reg.descuento,
        usuario: this.usuario,
        reactivar: reg.reactivar,
        tipo_descto: reg.tipo_descto
      };
      let resp = await this.api('baja', params);
      this.mensaje = resp.message;
      if (resp.ok) {
        this.buscarFolio();
      }
    },
    async reactivarDescuento() {
      if (!this.folio) return;
      let tipo = this.tiposDescuento[this.tipoSelIdx] || this.registros[0];
      let params = {
        control_rcm: this.folio,
        axo: new Date().getFullYear(),
        usuario: this.usuario,
        reactivar: 'S',
        tipo_descto: tipo.tipo_descto
      };
      let resp = await this.api('reactivar', params);
      this.mensaje = resp.message;
      if (resp.ok) {
        this.buscarFolio();
      }
    },
    async api(action, params) {
      try {
        let res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ eRequest: { action, ...params } })
        });
        let data = await res.json();
        return data.eResponse;
      } catch (e) {
        return { ok: false, message: 'Error de red', data: null };
      }
    }
  }
};
</script>

<style scoped>
.descuentos-page {
  max-width: 900px;
  margin: 0 auto;
  padding: 2rem;
}
.breadcrumb {
  margin-bottom: 1rem;
}
.form-section, .adeudos-section, .tipos-section, .registros-section {
  margin-bottom: 2rem;
}
.table {
  width: 100%;
  border-collapse: collapse;
  margin-bottom: 1rem;
}
.table th, .table td {
  border: 1px solid #ccc;
  padding: 0.5rem;
}
.mensaje {
  background: #f8f8d7;
  color: #333;
  padding: 1rem;
  border: 1px solid #e2e2a2;
  margin-top: 1rem;
}
</style>
